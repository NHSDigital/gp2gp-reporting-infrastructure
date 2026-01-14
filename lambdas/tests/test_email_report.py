import os
from pathlib import Path

import pytest

from lambdas.email_report import main as email_report


@pytest.fixture
def report_metadata():
    # Matches the keys your code expects
    return {
        "technical-failures-percentage": "1.23",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
        "reporting-window-end-datetime": "2025-01-08T00:00:00+0000",
        "report-name": "weekly-transfer-report",
        "config-cutoff-days": "7",
        "total-technical-failures": "10",
        "total-transfers": "1000",
        "send-email-notification": "true",
    }


@pytest.fixture
def s3_event():
    return {
        "Records": [
            {
                "s3": {
                    "bucket": {"name": "my-bucket"},
                    "object": {"key": "reports/report.csv"},
                }
            }
        ]
    }


class FakeSSM:
    def __init__(self, params: dict[str, str]):
        self._params = params
        self.calls: list[tuple[str, bool]] = []

    def get_parameter(self, Name: str, WithDecryption: bool):
        self.calls.append((Name, WithDecryption))
        if Name not in self._params:
            raise KeyError(f"Missing param: {Name}")
        return {"Parameter": {"Value": self._params[Name]}}


class FakeS3:
    def __init__(self, metadata: dict[str, str], file_bytes: bytes = b"col1,col2\n1,2\n"):
        self._metadata = metadata
        self._file_bytes = file_bytes
        self.get_object_calls: list[tuple[str, str]] = []
        self.download_calls: list[tuple[str, str, str]] = []

    def get_object(self, Bucket: str, Key: str):
        self.get_object_calls.append((Bucket, Key))
        return {"Metadata": self._metadata}

    def download_file(self, Bucket: str, Key: str, Filename: str):
        self.download_calls.append((Bucket, Key, Filename))
        # Write a dummy file where the lambda expects it (e.g., /tmp/report.csv)
        Path(Filename).write_bytes(self._file_bytes)


class FakeSMTP:
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.started_tls = False
        self.logged_in: tuple[str, str] | None = None
        self.sent: list[tuple[str, str, str]] = []
        self.closed = False

    def starttls(self):
        self.started_tls = True

    def login(self, user: str, password: str):
        self.logged_in = (user, password)

    def sendmail(self, sender: str, recipient: str, message: str):
        self.sent.append((sender, recipient, message))

    def quit(self):
        self.closed = True


def _set_required_env(monkeypatch):
    monkeypatch.setenv("EMAIL_REPORT_SENDER_EMAIL_PARAM_NAME", "/email/sender")
    monkeypatch.setenv("EMAIL_REPORT_SENDER_EMAIL_KEY_PARAM_NAME", "/email/key")
    monkeypatch.setenv("EMAIL_REPORT_RECIPIENT_EMAIL_PARAM_NAME", "/email/recipient")
    monkeypatch.setenv("EMAIL_REPORT_RECIPIENT_INTERNAL_EMAIL_PARAM_NAME", "/email/recipient_internal")


def test_ssm_secret_manager_get_secret():
    ssm = FakeSSM({"/foo": "bar"})
    mgr = email_report.SsmSecretManager(ssm)
    assert mgr.get_secret("/foo") == "bar"
    assert ssm.calls == [("/foo", True)]


def test_should_send_email_notification_true(report_metadata):
    assert email_report._should_send_email_notification(report_metadata) is True


@pytest.mark.parametrize("val", ["false", "FALSE", "FaLsE"])
def test_should_send_email_notification_false(report_metadata, val):
    md = dict(report_metadata)
    md["send-email-notification"] = val
    assert email_report._should_send_email_notification(md) is False


def test_construct_email_subject(report_metadata):
    subject = email_report._construct_email_subject(report_metadata)
    # Start datetime: 2025-01-01 -> Wed 01 January, 25
    # End datetime is minus 1 day: 2025-01-08 -> Tue 07 January, 25
    assert "GP2GP Report: Wed 01 January, 25 - Tue 07 January, 25" in subject
    assert "(weekly-transfer-report - Cutoff days: 7)" in subject


def test_construct_email_body_contains_expected_fields(report_metadata):
    body = email_report._construct_email_body("Heading", report_metadata)
    assert "<h1>GP2GP Report</h1>" in body
    assert "<h3>Heading</h3>" in body
    assert "Technical failures percentage" in body
    assert "1.23%" in body
    assert "Report name" in body
    assert "weekly-transfer-report" in body
    assert "Cutoff days" in body
    assert "7" in body
    assert "Total transfers" in body
    assert "1000" in body
    # Start date should be formatted; end date should be minus one day
    assert "Start Date:" in body
    assert "End date:" in body


def test_format_end_datetime_minus_one_day():
    # 2025-01-08 -> "Tuesday 07 January, 2025" with -1 day
    result = email_report._format_end_datetime("2025-01-08T00:00:00+0000")
    assert result == "Tuesday 07 January, 2025"


def test_lambda_handler_sends_two_emails_when_notification_true(monkeypatch, s3_event, report_metadata):
    _set_required_env(monkeypatch)

    # Fake AWS clients
    fake_ssm = FakeSSM(
        {
            "/email/sender": "sender@example.com",
            "/email/key": "super-secret",
            "/email/recipient": "recipient@example.com",
            "/email/recipient_internal": "internal@example.com",
        }
    )
    fake_s3 = FakeS3(metadata=report_metadata)

    # Patch boto3.client to return our fakes
    def fake_boto3_client(service_name: str):
        if service_name == "ssm":
            return fake_ssm
        if service_name == "s3":
            return fake_s3
        raise AssertionError(f"Unexpected boto3 client: {service_name}")

    monkeypatch.setattr(email_report.boto3, "client", fake_boto3_client)

    # Patch SMTP to capture messages
    created_smtp: list[FakeSMTP] = []

    def fake_smtp_ctor(host: str, port: int):
        smtp = FakeSMTP(host, port)
        created_smtp.append(smtp)
        return smtp

    monkeypatch.setattr(email_report.smtplib, "SMTP", fake_smtp_ctor)

    # Execute
    email_report.lambda_handler(s3_event, context=None)

    # Assertions: S3 object metadata retrieved and file downloaded
    assert fake_s3.get_object_calls == [("my-bucket", "reports/report.csv")]
    assert len(fake_s3.download_calls) == 1
    assert fake_s3.download_calls[0][0:2] == ("my-bucket", "reports/report.csv")
    assert fake_s3.download_calls[0][2].endswith("/tmp/report.csv")

    # SMTP interactions: one connection, TLS, login, and two sendmail calls
    assert len(created_smtp) == 1
    smtp = created_smtp[0]
    assert smtp.host == "smtp.office365.com"
    assert smtp.port == 587
    assert smtp.started_tls is True
    assert smtp.logged_in == ("sender@example.com", "super-secret")

    assert len(smtp.sent) == 2
    assert smtp.sent[0][0] == "sender@example.com"
    assert smtp.sent[0][1] == "internal@example.com"
    assert smtp.sent[1][1] == "recipient@example.com"

    # Basic sanity: message contains subject and multipart markers
    msg1 = smtp.sent[0][2]
    assert "Subject: GP2GP Report:" in msg1
    assert "Content-Type: multipart/mixed" in msg1
    assert "Content-Disposition: attachment" in msg1


def test_lambda_handler_skips_email_when_notification_false(monkeypatch, s3_event, report_metadata):
    _set_required_env(monkeypatch)

    md = dict(report_metadata)
    md["send-email-notification"] = "false"

    fake_ssm = FakeSSM(
        {
            "/email/sender": "sender@example.com",
            "/email/key": "super-secret",
            "/email/recipient": "recipient@example.com",
            "/email/recipient_internal": "internal@example.com",
        }
    )
    fake_s3 = FakeS3(metadata=md)

    def fake_boto3_client(service_name: str):
        return fake_ssm if service_name == "ssm" else fake_s3

    monkeypatch.setattr(email_report.boto3, "client", fake_boto3_client)

    created_smtp: list[FakeSMTP] = []

    def fake_smtp_ctor(host: str, port: int):
        smtp = FakeSMTP(host, port)
        created_smtp.append(smtp)
        return smtp

    monkeypatch.setattr(email_report.smtplib, "SMTP", fake_smtp_ctor)

    email_report.lambda_handler(s3_event, context=None)

    # Ensures we did not even create an SMTP client
    assert created_smtp == []


def test_lambda_handler_handles_smtp_exception(monkeypatch, s3_event, report_metadata):
    _set_required_env(monkeypatch)

    fake_ssm = FakeSSM(
        {
            "/email/sender": "sender@example.com",
            "/email/key": "super-secret",
            "/email/recipient": "recipient@example.com",
            "/email/recipient_internal": "internal@example.com",
        }
    )
    fake_s3 = FakeS3(metadata=report_metadata)

    def fake_boto3_client(service_name: str):
        return fake_ssm if service_name == "ssm" else fake_s3

    monkeypatch.setattr(email_report.boto3, "client", fake_boto3_client)

    class ExplodingSMTP(FakeSMTP):
        def sendmail(self, sender: str, recipient: str, message: str):
            raise RuntimeError("SMTP send failure")

    def exploding_smtp_ctor(host: str, port: int):
        return ExplodingSMTP(host, port)

    monkeypatch.setattr(email_report.smtplib, "SMTP", exploding_smtp_ctor)

    # Should not raise; lambda_handler catches Exception and returns
    email_report.lambda_handler(s3_event, context=None)
