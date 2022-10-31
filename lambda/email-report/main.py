import os.path
import boto3
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)
    s3 = boto3.client("s3")

    print("Event: ", event)

    FILEOBJ = event["Records"][0]
    BUCKET_NAME = str(FILEOBJ['s3']['bucket']['name'])
    KEY = str(FILEOBJ['s3']['object']['key'])
    FILE_NAME = os.path.basename(KEY)
    TMP_FILE_NAME = '/tmp/' + FILE_NAME

    transfer_report_meta_data = s3.get_object(Bucket=BUCKET_NAME, Key=KEY)['Metadata']
    print("Report metadata:", transfer_report_meta_data)

    # Download the file/s from the event (extracted above) to the tmp location
    s3.download_file(BUCKET_NAME, KEY, TMP_FILE_NAME)

    BODY_TEXT = "Please see the report attached."
    BODY_HTML = _construct_email_body(BODY_TEXT, transfer_report_meta_data)
    SUBJECT = _construct_email_subject(transfer_report_meta_data)

    SENDER = secret_manager.get_secret(os.environ["EMAIL_REPORT_SENDER_EMAIL_PARAM_NAME"])
    SENDER_KEY = secret_manager.get_secret(os.environ["EMAIL_REPORT_SENDER_EMAIL_KEY_PARAM_NAME"])
    RECIPIENT = secret_manager.get_secret(os.environ["EMAIL_REPORT_RECIPIENT_EMAIL_PARAM_NAME"])
    RECIPIENT_INTERNAL = secret_manager.get_secret(os.environ["EMAIL_REPORT_RECIPIENT_INTERNAL_EMAIL_PARAM_NAME"])

    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER

    CHARSET = "utf-8"
    textpart = MIMEText(BODY_TEXT.encode(CHARSET), 'plain', CHARSET)
    htmlpart = MIMEText(BODY_HTML.encode(CHARSET), 'html', CHARSET)

    msg_body = MIMEMultipart('alternative')
    msg_body.attach(textpart)
    msg_body.attach(htmlpart)

    att = MIMEApplication(open(TMP_FILE_NAME, 'rb').read())
    att.add_header('Content-Disposition', 'attachment', filename=os.path.basename(TMP_FILE_NAME))

    msg.attach(msg_body)
    msg.attach(att)

    if _is_manually_generated_report(transfer_report_meta_data):
        print("Report was manually generated. Skipping sending email to: " + RECIPIENT + " and " + RECIPIENT + " with the following metadata: ", transfer_report_meta_data)
        return

    try:
        server = smtplib.SMTP("smtp.office365.com", 587)
        server.starttls()
        server.login(SENDER, SENDER_KEY)

        msg['To'] = RECIPIENT_INTERNAL
        server.sendmail(SENDER, RECIPIENT_INTERNAL, msg.as_string())
        print('Email successfully sent to: ', RECIPIENT_INTERNAL)

        msg['To'] = RECIPIENT
        server.sendmail(SENDER, RECIPIENT, msg.as_string())
        print('Email successfully sent to: ', RECIPIENT)
    except Exception as e:
        print("Failed to send email")
        print("Exception: ", e)
        return


def _construct_email_subject(transfer_report_meta_data):
    return "GP2GP Report: " + \
           _format_start_datetime_short(transfer_report_meta_data['reporting-window-start-datetime']) + \
           " - " + \
           _format_end_datetime_short(transfer_report_meta_data['reporting-window-end-datetime']) + \
           " (" + \
           str(transfer_report_meta_data['report-name']) + \
           " - Cutoff days: " + \
           str(transfer_report_meta_data['config-cutoff-days']) + \
           ")"


def _construct_email_body(body_heading, transfer_report_meta_data):
    return """\
    <html>
    <head></head>
    <body>
    <h1>GP2GP Report</h1>
    <h3>""" + body_heading + """</h3>
    <ul>
    <li style="padding: 2px;">Technical failures percentage: <strong>""" + str(
        transfer_report_meta_data['technical-failures-percentage']) + """%</strong></li>
    <li style="padding: 2px;">Start Date: """ + _format_start_datetime(transfer_report_meta_data['reporting-window-start-datetime']) + """</li>
    <li style="padding: 2px;">End date: """ + _format_end_datetime(transfer_report_meta_data['reporting-window-end-datetime']) + """</li>
    <li style="padding: 2px;">Report name: """ + str(transfer_report_meta_data['report-name']) + """</li>
    <li style="padding: 2px;">Cutoff days: """ + str(transfer_report_meta_data['config-cutoff-days']) + """</li>
    <li style="padding: 2px;">Total technical failures: """ + str(
        transfer_report_meta_data['total-technical-failures']) + """</li>
    <li style="padding: 2px;">Total transfers: """ + str(transfer_report_meta_data['total-transfers']) + """</li>
    </ul>
    </body>
    </html>
    """


def _is_manually_generated_report(transfer_report_meta_data):
    if transfer_report_meta_data['config-start-datetime'] != 'None':
        return True

    return False


def _format_start_datetime(iso_datetime):
    return (datetime.strptime(iso_datetime, '%Y-%m-%dT%H:%M:%S%z').strftime("%A %d %B, %Y"))


def _format_end_datetime(iso_datetime):
    return (datetime.strptime(iso_datetime, '%Y-%m-%dT%H:%M:%S%z') - timedelta(days=1)).strftime("%A %d %B, %Y")


def _format_start_datetime_short(iso_datetime):
    return datetime.strptime(iso_datetime, '%Y-%m-%dT%H:%M:%S%z') \
        .strftime("%a %d %B, %y")


def _format_end_datetime_short(iso_datetime):
    return (datetime.strptime(iso_datetime, '%Y-%m-%dT%H:%M:%S%z') - timedelta(days=1)).strftime("%a %d %B, %y")