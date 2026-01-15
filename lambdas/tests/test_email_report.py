from pathlib import Path
from unittest.mock import Mock

import pytest

from lambdas.email_report import main as email_report


def set_required_env(monkeypatch):
    monkeypatch.setenv("EMAIL_REPORT_SENDER_EMAIL_PARAM_NAME", "/email/sender")
    monkeypatch.setenv("EMAIL_REPORT_SENDER_EMAIL_KEY_PARAM_NAME", "/email/key")
    monkeypatch.setenv("EMAIL_REPORT_RECIPIENT_EMAIL_PARAM_NAME", "/email/recipient")
    monkeypatch.setenv("EMAIL_REPORT_RECIPIENT_INTERNAL_EMAIL_PARAM_NAME", "/email/recipient_internal")


def s3_event(bucket="my-bucket", key="reports/report.csv"):
    return {"Records": [{"s3": {"bucket": {"name": bucket}, "object": {"key": key}}}]}


def report_metadata(send="true"):
    return {
        "technical-failures-percentage": "1.23",
        "reporting-window-start-datetime": "2025-01-01T00:00:00+0000",
        "reporting-window-end-datetime": "2025-01-08T00:00:00+0000",
        "report-name": "weekly-transfer-report",
        "config-cutoff-days": "7",
        "total-technical-failures": "10",
        "total-transfers": "1000",
        "send-email-notification": send,
    }


def mock_ssm(monkeypatch):
    ssm = Mock()
    ssm.get_parameter.side_effect = lambda Name, WithDecryption: {
        "Parameter": {
            "Value": {
                "/email/sender": "sender@example.com",
                "/email/key": "super-secret",
                "/email/recipient": "recipient@example.com",
                "/email/recipient_internal": "internal@example.com",
            }[Name]
        }
    }
    return ssm


def mock_s3(monkeypatch, *, metadata, file_bytes=b"col1,col2\n1,2\n"):
    s3 = Mock()
    s3.get_object.return_value = {"Metadata": metadata}

    def download_file(Bucket, Key, Filename):
        Path(Filename).write_bytes(file_bytes)

    s3.download_file.side_effect = download_file
    return s3


def mock_boto3(monkeypatch, *, ssm, s3):
    def client(service):
        if service == "ssm":
            return ssm
        if service == "s3":
            return s3
        raise AssertionError(f"Unexpected boto3 client: {service}")

    monkeypatch.setattr(email_report.boto3, "client", client)


def mock_smtp(monkeypatch, *, explode_on_send=False):
    smtp = Mock()
    if explode_on_send:
        smtp.sendmail.side_effect = RuntimeError("SMTP send failure")

    monkeypatch.setattr(email_report.smtplib, "SMTP", lambda host, port: smtp)
    return smtp


def test_should_send_email_notification_true():
    assert email_report._should_send_email_notification(report_metadata("true")) is True


@pytest.mark.parametrize("val", ["false", "FALSE", "FaLsE"])
def test_should_send_email_notification_false(val):
    assert email_report._should_send_email_notification(report_metadata(val)) is False


def test_construct_subject_contains_dates_and_cutoff():
    subject = email_report._construct_email_subject(report_metadata("true"))
    assert "GP2GP Report:" in subject
    assert "weekly-transfer-report" in subject
    assert "Cutoff days: 7" in subject


def test_lambda_handler_sends_two_emails(monkeypatch):
    set_required_env(monkeypatch)

    ssm = mock_ssm(monkeypatch)
    s3 = mock_s3(monkeypatch, metadata=report_metadata("true"))
    mock_boto3(monkeypatch, ssm=ssm, s3=s3)

    smtp = mock_smtp(monkeypatch)

    email_report.lambda_handler(s3_event(), None)

    # S3 interactions
    s3.get_object.assert_called_once_with(Bucket="my-bucket", Key="reports/report.csv")
    assert s3.download_file.call_count == 1

    # SMTP interactions
    smtp.starttls.assert_called_once()
    smtp.login.assert_called_once_with("sender@example.com", "super-secret")
    assert smtp.sendmail.call_count == 2

    # recipients are internal then external
    recipients = [c.args[1] for c in smtp.sendmail.call_args_list]
    assert recipients == ["internal@example.com", "recipient@example.com"]


def test_lambda_handler_skips_when_notification_false(monkeypatch):
    set_required_env(monkeypatch)

    ssm = mock_ssm(monkeypatch)
    s3 = mock_s3(monkeypatch, metadata=report_metadata("false"))
    mock_boto3(monkeypatch, ssm=ssm, s3=s3)

    smtp = mock_smtp(monkeypatch)

    email_report.lambda_handler(s3_event(), None)

    smtp.sendmail.assert_not_called()
    smtp.login.assert_not_called()


def test_lambda_handler_catches_smtp_exception(monkeypatch):
    set_required_env(monkeypatch)

    ssm = mock_ssm(monkeypatch)
    s3 = mock_s3(monkeypatch, metadata=report_metadata("true"))
    mock_boto3(monkeypatch, ssm=ssm, s3=s3)

    mock_smtp(monkeypatch, explode_on_send=True)

    # Should not raise; handler catches Exception and returns
    email_report.lambda_handler(s3_event(), None)
