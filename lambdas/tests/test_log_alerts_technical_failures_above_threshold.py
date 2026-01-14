import base64
import json
import os
import zlib
from dataclasses import dataclass

import pytest
from botocore.exceptions import ClientError

from lambdas.log_alerts_technical_failures_above_threshold import main as tf_alerts


class FakeSSM:
    def __init__(self, params: dict[str, str]):
        self._params = params
        self.calls: list[tuple[str, bool]] = []

    def get_parameter(self, Name: str, WithDecryption: bool):
        self.calls.append((Name, WithDecryption))
        if Name not in self._params:
            raise KeyError(f"Missing param: {Name}")
        return {"Parameter": {"Value": self._params[Name]}}


@dataclass
class FakeHTTPResponse:
    status: int = 200
    data: bytes = b"ok"


class FakeHTTP:
    def __init__(self):
        self.requests: list[tuple[str, str, bytes]] = []  # (method, url, body)
        self._next_responses: list[FakeHTTPResponse] = []

    def queue_response(self, resp: FakeHTTPResponse):
        self._next_responses.append(resp)

    def request(self, method: str, url: str, body: bytes):
        self.requests.append((method, url, body))
        if self._next_responses:
            return self._next_responses.pop(0)
        return FakeHTTPResponse()


def _set_required_env(monkeypatch):
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_WEBHOOK_URL_PARAM_NAME", "/webhook/daily")
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME", "/threshold/rate")
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_WEBHOOK_URL_PARAM_NAME", "/webhook/threshold")
    monkeypatch.setenv("LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME", "/webhook/general")


def _make_cloudwatch_logs_event(message_dict: dict) -> dict:
    """
    Builds the CloudWatch Logs subscription event payload expected by the lambda.
    Your code does: decode(event["awslogs"]["data"]) -> json payload with logEvents[0].message (stringified json)
    """
    payload = {
        "messageType": "DATA_MESSAGE",
        "owner": "123456789012",
        "logGroup": "/aws/lambda/something",
        "logStream": "stream",
        "subscriptionFilters": ["filter"],
        "logEvents": [{"id": "1", "timestamp": 0, "message": json.dumps(message_dict)}],
    }
    raw = json.dumps(payload).encode("utf-8")

    # The lambda uses zlib.decompress(..., 16+MAX_WBITS) which expects gzip wrapper.
    gz = zlib.compressobj(wbits=16 + zlib.MAX_WBITS)
    compressed = gz.compress(raw) + gz.flush()

    b64 = base64.b64encode(compressed).decode("utf-8")
    return {"awslogs": {"data": b64}}


def test_decode_roundtrip():
    message = {"hello": "world"}
    event = _make_cloudwatch_logs_event({"x": "y"})
    decoded = tf_alerts.decode(event["awslogs"]["data"])
    assert "logEvents" in decoded
    assert decoded["logEvents"][0]["message"]  # string


def test_ssm_secret_manager_get_secret():
    ssm = FakeSSM({"/a": "b"})
    mgr = tf_alerts.SsmSecretManager(ssm)
    assert mgr.get_secret("/a") == "b"
    assert ssm.calls == [("/a", True)]


def test_lambda_handler_sends_only_daily_alert_when_below_threshold(monkeypatch):
    _set_required_env(monkeypatch)

    # Under threshold: 5% vs threshold 10
    msg = {
        "percent-of-technical-failures": "5",
        "total-technical-failures": "2",
        "total-transfers": "40",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
    }
    event = _make_cloudwatch_logs_event(msg)

    fake_http = FakeHTTP()
    # queue a response for the daily webhook
    fake_http.queue_response(FakeHTTPResponse(status=200, data=b"daily-ok"))
    monkeypatch.setattr(tf_alerts, "http", fake_http)

    fake_ssm = FakeSSM(
        {
            "/webhook/daily": "https://example.com/daily",
            "/threshold/rate": "10",
            "/webhook/threshold": "https://example.com/threshold",
            "/webhook/general": "https://example.com/general",
        }
    )

    def fake_boto3_client(service_name: str):
        assert service_name == "ssm"
        return fake_ssm

    monkeypatch.setattr(tf_alerts.boto3, "client", fake_boto3_client)

    tf_alerts.lambda_handler(event, context=None)

    # Only daily webhook called
    assert len(fake_http.requests) == 1
    method, url, body = fake_http.requests[0]
    assert method == "POST"
    assert url == "https://example.com/daily"

    sent = json.loads(body.decode("utf-8"))
    assert sent["textFormat"] == "markdown"
    assert "Daily technical failure rate" in sent["text"]
    assert "Percent of technical failures" in sent["text"]


def test_lambda_handler_sends_daily_and_threshold_and_general_when_above_threshold(monkeypatch):
    _set_required_env(monkeypatch)

    # Above threshold: 15% vs threshold 10
    msg = {
        "percent-of-technical-failures": "15",
        "total-technical-failures": "30",
        "total-transfers": "200",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
    }
    event = _make_cloudwatch_logs_event(msg)

    fake_http = FakeHTTP()
    # daily, threshold, general
    fake_http.queue_response(FakeHTTPResponse(status=200, data=b"daily-ok"))
    fake_http.queue_response(FakeHTTPResponse(status=200, data=b"threshold-ok"))
    fake_http.queue_response(FakeHTTPResponse(status=200, data=b"general-ok"))
    monkeypatch.setattr(tf_alerts, "http", fake_http)

    fake_ssm = FakeSSM(
        {
            "/webhook/daily": "https://example.com/daily",
            "/threshold/rate": "10",
            "/webhook/threshold": "https://example.com/threshold",
            "/webhook/general": "https://example.com/general",
        }
    )

    def fake_boto3_client(service_name: str):
        assert service_name == "ssm"
        return fake_ssm

    monkeypatch.setattr(tf_alerts.boto3, "client", fake_boto3_client)

    tf_alerts.lambda_handler(event, context=None)

    assert len(fake_http.requests) == 3
    assert fake_http.requests[0][1] == "https://example.com/daily"
    assert fake_http.requests[1][1] == "https://example.com/threshold"
    assert fake_http.requests[2][1] == "https://example.com/general"

    # Body for threshold/general should contain the "above the threshold" heading
    threshold_body = json.loads(fake_http.requests[1][2].decode("utf-8"))
    assert "Technical failures are above the threshold" in threshold_body["text"]


def test_lambda_handler_handles_client_error(monkeypatch):
    _set_required_env(monkeypatch)

    msg = {
        "percent-of-technical-failures": "5",
        "total-technical-failures": "2",
        "total-transfers": "40",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
    }
    event = _make_cloudwatch_logs_event(msg)

    # Arrange http.request to raise a ClientError
    class ExplodingHTTP(FakeHTTP):
        def request(self, method: str, url: str, body: bytes):
            raise ClientError(
                error_response={"Error": {"Code": "X", "Message": "Boom"}},
                operation_name="Request",
            )

    exploding_http = ExplodingHTTP()
    monkeypatch.setattr(tf_alerts, "http", exploding_http)

    fake_ssm = FakeSSM(
        {
            "/webhook/daily": "https://example.com/daily",
            "/threshold/rate": "10",
            "/webhook/threshold": "https://example.com/threshold",
            "/webhook/general": "https://example.com/general",
        }
    )

    def fake_boto3_client(service_name: str):
        assert service_name == "ssm"
        return fake_ssm

    monkeypatch.setattr(tf_alerts.boto3, "client", fake_boto3_client)

    # Should not raise; lambda catches ClientError
    tf_alerts.lambda_handler(event, context=None)


def test_lambda_handler_handles_generic_exception(monkeypatch):
    _set_required_env(monkeypatch)

    msg = {
        "percent-of-technical-failures": "5",
        "total-technical-failures": "2",
        "total-transfers": "40",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
    }
    event = _make_cloudwatch_logs_event(msg)

    class ExplodingHTTP(FakeHTTP):
        def request(self, method: str, url: str, body: bytes):
            raise RuntimeError("Boom")

    monkeypatch.setattr(tf_alerts, "http", ExplodingHTTP())

    fake_ssm = FakeSSM(
        {
            "/webhook/daily": "https://example.com/daily",
            "/threshold/rate": "10",
            "/webhook/threshold": "https://example.com/threshold",
            "/webhook/general": "https://example.com/general",
        }
    )

    def fake_boto3_client(service_name: str):
        assert service_name == "ssm"
        return fake_ssm

    monkeypatch.setattr(tf_alerts.boto3, "client", fake_boto3_client)

    # Should not raise; lambda catches Exception
    tf_alerts.lambda_handler(event, context=None)
