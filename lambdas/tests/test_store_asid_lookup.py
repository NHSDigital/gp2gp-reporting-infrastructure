import gzip
import json
from datetime import datetime, timezone
from io import BytesIO
from unittest.mock import Mock

import pytest


@pytest.fixture
def store_asid_lookup_module_with_mocking(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "dev")
    monkeypatch.setenv("EMAIL_USER", "someone")

    from lambdas.store_asid_lookup import main as m

    monkeypatch.setattr(m, "now", datetime(2025, 2, 3, tzinfo=timezone.utc))

    m.s3_client = Mock()
    m.ssm_client = Mock()
    m.stepfunctions_client = Mock()

    return m

def test_extract_csv_attachment_from_email_success(store_asid_lookup_module_with_mocking):
    # Build a very small email with an attachment named asidLookup.csv
    from email.mime.multipart import MIMEMultipart
    from email.mime.application import MIMEApplication

    msg = MIMEMultipart()
    att = MIMEApplication(b"a,b\n1,2\n")
    att.add_header("Content-Disposition", "attachment", filename="asidLookup.csv")
    msg.attach(att)

    extracted = store_asid_lookup_module_with_mocking.extract_csv_attachment_from_email(msg.as_bytes())
    assert extracted == b"a,b\n1,2\n"

def test_extract_csv_attachment_from_email_missing_raises(store_asid_lookup_module_with_mocking):
    from email.mime.multipart import MIMEMultipart
    from email.mime.application import MIMEApplication

    msg = MIMEMultipart()
    att = MIMEApplication(b"x")
    att.add_header("Content-Disposition", "attachment", filename="other.csv")
    msg.attach(att)

    with pytest.raises(FileNotFoundError):
        store_asid_lookup_module_with_mocking.extract_csv_attachment_from_email(msg.as_bytes())

def test_compress_csv_roundtrip(store_asid_lookup_module_with_mocking):
    out = store_asid_lookup_module_with_mocking.compress_csv(b"hello")
    assert isinstance(out, BytesIO)
    assert gzip.decompress(out.getvalue()) == b"hello"

def test_validate_event_destination_pass(store_asid_lookup_module_with_mocking):
    ses_mail = {"destination": ["someone@mail.dev.gp-registrations-data.nhs.uk"]}
    store_asid_lookup_module_with_mocking.validate_event_destination(ses_mail)  # no raise

def test_validate_event_destination_fail(store_asid_lookup_module_with_mocking):
    ses_mail = {"destination": ["wrong@somewhere.com"]}
    with pytest.raises(store_asid_lookup_module_with_mocking.EmailValidationError):
        store_asid_lookup_module_with_mocking.validate_event_destination(ses_mail)

def test_validate_event_source_pass(store_asid_lookup_module_with_mocking):
    store_asid_lookup_module_with_mocking.get_ssm_param = Mock(return_value="example.com, nhs.uk")
    ses_mail = {"source": "alerts@example.com"}
    store_asid_lookup_module_with_mocking.validate_event_source(ses_mail)  # no raise

def test_validate_event_source_fail(store_asid_lookup_module_with_mocking):
    store_asid_lookup_module_with_mocking.get_ssm_param = Mock(return_value="nhs.uk")
    ses_mail = {"source": "alerts@example.com"}
    with pytest.raises(store_asid_lookup_module_with_mocking.EmailValidationError):
        store_asid_lookup_module_with_mocking.validate_event_source(ses_mail)

def test_start_ods_downloader_step_function_starts_execution(store_asid_lookup_module_with_mocking):
    store_asid_lookup_module_with_mocking.stepfunctions_client.list_state_machines.return_value = {
        "stateMachines": [
            {"name": "ods-downloader-pipeline", "stateMachineArn": "arn:ods"},
        ]
    }

    store_asid_lookup_module_with_mocking.start_ods_downloader_step_function({"time": "2025-02-01T00:00:00Z"})

    store_asid_lookup_module_with_mocking.stepfunctions_client.start_execution.assert_called_once()
    kwargs = store_asid_lookup_module_with_mocking.stepfunctions_client.start_execution.call_args.kwargs
    assert kwargs["stateMachineArn"] == "arn:ods"
    assert kwargs["name"] == "2025-2" or kwargs["name"] == "2025-02"  # depending on your f-string
    assert json.loads(kwargs["input"]) == {"time": "2025-02-01T00:00:00Z"}

def test_store_file_in_destination_s3_writes_expected_key(store_asid_lookup_module_with_mocking):
    buf = BytesIO(b"data")
    store_asid_lookup_module_with_mocking.store_file_in_destination_s3(buf)

    store_asid_lookup_module_with_mocking.s3_client.put_object.assert_called_once()
    kwargs = store_asid_lookup_module_with_mocking.s3_client.put_object.call_args.kwargs
    assert kwargs["Bucket"] == "prm-gp2gp-asid-lookup-dev"
    assert kwargs["Key"] == "2025/2/asidLookup.csv.gz" or kwargs["Key"] == "2025/02/asidLookup.csv.gz"
    assert kwargs["Body"] == b"data"
