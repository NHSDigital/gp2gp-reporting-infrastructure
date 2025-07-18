import boto3
import gzip
import email
import os
from datetime import datetime, timezone
from io import BytesIO
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
ssm_client = boto3.client('ssm')

# Constants
environment = os.environ["ENVIRONMENT"]
email_user = os.environ["EMAIL_USER"]

expected_email_destination = (
    f"{email_user}@mail.gp-registrations-data.nhs.uk"
    if environment == "prod"
    else f"{email_user}@mail.{environment}.gp-registrations-data.nhs.uk"
)
permitted_emails_ssm_location = f"/registrations/{environment}/data-pipeline/gp2gp-dashboard/permitted-emails"
source_s3_bucket_ssm_location = f'/registrations/{environment}/data-pipeline/gp2gp-dashboard/email-storage-bucket-name'
asid_lookup_filename = "asidLookup.csv"
asid_lookup_s3_filekey_prefix = "asid_lookup"
destination_s3_bucket = f"prm-gp2gp-asid-lookup-{environment}"


def lambda_handler(event, context):
    email_event = event['Records'][0]

    message_id = email_event['ses']['mail']['messageId']
    print(f"Processing email with messageId: {message_id}")

    validate_email_event(email_event)
    raw_email = get_raw_email_from_source_s3(email_event)
    attached_csv = extract_csv_attachment_from_email(raw_email)
    compressed_csv = compress_csv(attached_csv)
    store_file_in_destination_s3(compressed_csv)


def validate_email_event(email_event: dict):
    ses_mail = email_event['ses']['mail']
    ses_receipt = email_event['ses']['receipt']

    try:
        validate_event_source(ses_mail)
        validate_event_destination(ses_mail)
        validate_event_headers(ses_mail)
        validate_event_receipt(ses_receipt)

        print("Email event validated successfully")
    except Exception as e:
        remove_email_from_s3(ses_mail['messageId'])
        raise e


def validate_event_source(ses_mail: dict):
    raw_permitted_emails = get_ssm_param(permitted_emails_ssm_location)  # permitted emails should be comma separated
    permitted_emails = [email_address.strip() for email_address in raw_permitted_emails.split(",")]

    source = ses_mail['source']

    if not any(source.endswith(email_address) for email_address in permitted_emails):
        raise EmailValidationError(f"Email not from permitted sender. Got: {source}")

    print(f"Source validation passed - email from permitted sender: {source}")


def validate_event_destination(ses_mail: dict):
    destination = ses_mail['destination']

    if expected_email_destination not in destination:
        raise EmailValidationError(f"Unexpected destination: {destination}")

    print('Destination validation passed')


def validate_event_headers(ses_mail: dict):
    headers = {h["name"]: h["value"] for h in ses_mail["headers"]}
    required_headers = {
        "X-SES-Spam-Verdict": "PASS",
        "X-SES-Virus-Verdict": "PASS",
        "X-MS-Has-Attach": "Yes",
    }

    for key, expected in required_headers.items():
        if headers.get(key) != expected:
            raise EmailValidationError(f"Email validation failed. Header {key} did not pass. Got: {headers.get(key)}")

    print('Header validation passed')


def validate_event_receipt(ses_receipt: dict):
    if not all([
        ses_receipt['spamVerdict']['status'] == 'PASS',
        ses_receipt['virusVerdict']['status'] == 'PASS',
        ses_receipt['spfVerdict']['status'] == 'PASS',
        ses_receipt['dkimVerdict']['status'] == 'PASS',
        ses_receipt['dmarcVerdict']['status'] == 'PASS',
    ]):
        raise EmailValidationError("Email validation failed due to incorrect receipt")

    print('Receipt validation passed')


def remove_email_from_s3(message_id: str):
    source_s3_bucket = get_ssm_param(source_s3_bucket_ssm_location)
    s3_file_key = f"{asid_lookup_s3_filekey_prefix}/{message_id}"

    try:
        s3_client.delete_object(Bucket=source_s3_bucket, Key=s3_file_key)
        print(f"Deleted email from S3: bucket={source_s3_bucket}, key={s3_file_key}")
    except ClientError as e:
        print(f"Failed to delete email from S3: bucket={source_s3_bucket}, key={s3_file_key}, error={e}")


def get_raw_email_from_source_s3(message_id: str):
    source_s3_bucket = get_ssm_param(source_s3_bucket_ssm_location)
    s3_file_key = f"{asid_lookup_s3_filekey_prefix}/{message_id}"

    try:
        response = s3_client.get_object(Bucket=source_s3_bucket, Key=s3_file_key)
        return response['Body'].read()
    except ClientError as e:
        raise RuntimeError(f"Failed to retrieve email from S3: bucket={source_s3_bucket}, key={s3_file_key}, error={e}")


def extract_csv_attachment_from_email(raw_email: bytes):
    msg = email.message_from_bytes(raw_email)
    for part in msg.walk():
        if part.get_filename() == asid_lookup_filename:
            return part.get_payload(decode=True)
    else:
        raise FileNotFoundError("asidLookup.csv not found in email")


def compress_csv(csv: bytes):
    output = BytesIO()
    with gzip.GzipFile(fileobj=output, mode="wb") as gz:
        gz.write(csv)

    output.seek(0)

    return output


def store_file_in_destination_s3(file: BytesIO):
    now = datetime.now(timezone.utc)
    file_key = f"{now.year}/{now.month}/{asid_lookup_filename}.gz"
    s3_client.put_object(Bucket=destination_s3_bucket, Key=file_key, Body=file.read())
    print(f"Successfully uploaded compressed file at {destination_s3_bucket}/{file_key}")


def get_ssm_param(name):
    return ssm_client.get_parameter(Name=name, WithDecryption=True)['Parameter']['Value']


class EmailValidationError(Exception):
    pass
