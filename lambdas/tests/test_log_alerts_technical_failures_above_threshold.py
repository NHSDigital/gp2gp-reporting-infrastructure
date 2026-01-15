import base64
import json
import zlib
from unittest.mock import Mock

import pytest
from unittest.mock import ANY
from botocore.exceptions import ClientError

from lambdas.log_alerts_technical_failures_above_threshold import main as tf_alerts


def cw_event(message_dict: dict) -> dict:
    """Build CloudWatch Logs subscription event payload expected by the lambda."""
    payload = {
        "logEvents": [{"message": json.dumps(message_dict)}],
    }
    raw = json.dumps(payload).encode("utf-8")

    # gzip wrapper (wbits=16+MAX_WBITS) to match lambda's zlib.decompress(..., 16+MAX_WBITS)
    gz = zlib.compressobj(wbits=16 + zlib.MAX_WBITS)
    compressed = gz.compress(raw) + gz.flush()

    return {"awslogs": {"data": base64.b64encode(compressed).decode("utf-8")}}


def set_required_env(monkeypatch):
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_WEBHOOK_URL_PARAM_NAME", "/webhook/daily")
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME", "/threshold/rate")
    monkeypatch.setenv("LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_WEBHOOK_URL_PARAM_NAME", "/webhook/threshold")
    monkeypatch.setenv("LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME", "/webhook/general")


def mock_ssm(monkeypatch, *, daily, threshold_rate, threshold, general):
    ssm = Mock()
    ssm.get_parameter.side_effect = lambda Name, WithDecryption: {
        "Parameter": {
            "Value": {
                "/webhook/daily": daily,
                "/threshold/rate": str(threshold_rate),
                "/webhook/threshold": threshold,
                "/webhook/general": general,
            }[Name]
        }
    }

    monkeypatch.setattr(tf_alerts.boto3, "client", lambda service: ssm)
    return ssm


def test_secret_manager_get_secret():
    ssm = Mock()
    ssm.get_parameter.return_value = {"Parameter": {"Value": "x"}}
    mgr = tf_alerts.SsmSecretManager(ssm)

    assert mgr.get_secret("/a") == "x"
    ssm.get_parameter.assert_called_once_with(Name="/a", WithDecryption=True)


def test_lambda_handler_below_threshold_sends_one_post(monkeypatch):
    set_required_env(monkeypatch)
    mock_ssm(
        monkeypatch,
        daily="https://example.com/daily",
        threshold_rate=10,
        threshold="https://example.com/threshold",
        general="https://example.com/general",
    )

    http = Mock()
    http.request.return_value = Mock(status=200, data=b"ok")
    monkeypatch.setattr(tf_alerts, "http", http)

    event = cw_event(
        {
            "percent-of-technical-failures": "5",
            "total-technical-failures": "2",
            "total-transfers": "40",
            "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
        }
    )

    tf_alerts.lambda_handler(event, None)

    assert http.request.call_count == 1
    http.request.assert_called_with(
        "POST", url="https://example.com/daily", body=ANY
    )


def test_lambda_handler_above_threshold_sends_three_posts(monkeypatch):
    set_required_env(monkeypatch)
    mock_ssm(
        monkeypatch,
        daily="https://example.com/daily",
        threshold_rate=10,
        threshold="https://example.com/threshold",
        general="https://example.com/general",
    )

    http = Mock()
    http.request.return_value = Mock(status=200, data=b"ok")
    monkeypatch.setattr(tf_alerts, "http", http)

    event = cw_event(
        {
            "percent-of-technical-failures": "15",
            "total-technical-failures": "30",
            "total-transfers": "200",
            "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
        }
    )

    tf_alerts.lambda_handler(event, None)

    assert http.request.call_count == 3
    urls = [c.kwargs["url"] for c in http.request.call_args_list]
    assert urls == [
        "https://example.com/daily",
        "https://example.com/threshold",
        "https://example.com/general",
    ]


def test_lambda_handler_catches_client_error(monkeypatch):
    set_required_env(monkeypatch)
    mock_ssm(
        monkeypatch,
        daily="https://example.com/daily",
        threshold_rate=10,
        threshold="https://example.com/threshold",
        general="https://example.com/general",
    )

    http = Mock()
    http.request.side_effect = ClientError(
        error_response={"Error": {"Code": "X", "Message": "Boom"}},
        operation_name="Request",
    )
    monkeypatch.setattr(tf_alerts, "http", http)

    event = cw_event(
        {
            "percent-of-technical-failures": "5",
            "total-technical-failures": "2",
            "total-transfers": "40",
            "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
        }
    )

    # Should not raise (lambda catches ClientError)
    tf_alerts.lambda_handler(event, None)
