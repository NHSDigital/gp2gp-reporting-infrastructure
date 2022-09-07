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

    technical_failure_threshold_rate = int(secret_manager.get_secret(os.environ["LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME"]))

    if _should_skip_email(transfer_report_meta_data, technical_failure_threshold_rate):
        print("Skipping email with the following metadata: ", transfer_report_meta_data)
        return

    # Download the file/s from the event (extracted above) to the tmp location
    s3.download_file(BUCKET_NAME, KEY, TMP_FILE_NAME)

    BODY_TEXT = "Please see the report attached."
    BODY_HTML = _construct_email_body(BODY_TEXT, transfer_report_meta_data)
    SUBJECT = _construct_email_subject(transfer_report_meta_data)

    SENDER = secret_manager.get_secret(os.environ["EMAIL_REPORT_SENDER_EMAIL_PARAM_NAME"])
    SENDER_KEY = secret_manager.get_secret(os.environ["EMAIL_REPORT_SENDER_EMAIL_KEY"])
    RECIPIENT = secret_manager.get_secret(os.environ["EMAIL_REPORT_RECIPIENT_EMAIL_PARAM_NAME"])

    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = RECIPIENT

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

    try:
        server = smtplib.SMTP("smtp.office365.com", 587)
        server.starttls()
        server.login(SENDER, SENDER_KEY)
        server.sendmail(SENDER, RECIPIENT, msg.as_string())
        print('Email Successfully Sent')
    except Exception as e:
        print("Failed to send email")
        print("Exception: ", e)
        return


def _construct_email_subject(transfer_report_meta_data):
    return "GP2GP Report: " + \
           _format_start_date(transfer_report_meta_data) + \
           " - " + \
           _format_end_date(transfer_report_meta_data) + \
           " (Technical failures: " + \
           str(transfer_report_meta_data['technical-failures-percentage']) + \
           "%)"


def _format_end_date(transfer_report_meta_data):
    return (datetime.strptime(transfer_report_meta_data['reporting-window-end-datetime'], '%Y-%m-%dT%H:%M:%S%z') -
            timedelta(days=1)).strftime("%A %d %B, %Y")


def _format_start_date(transfer_report_meta_data):
    return datetime.strptime(transfer_report_meta_data['reporting-window-start-datetime'], '%Y-%m-%dT%H:%M:%S%z') \
        .strftime("%A %d %B, %Y")


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
    <li style="padding: 2px;">Start Date: """ + _format_start_date(transfer_report_meta_data) + """</li>
    <li style="padding: 2px;">End date: """ + _format_end_date(transfer_report_meta_data) + """</li>
    <li style="padding: 2px;">Report Name: """ + str(transfer_report_meta_data['report-name']) + """</li>
    <li style="padding: 2px;">Cutoff: """ + str(transfer_report_meta_data['config-cutoff-days']) + """</li>
    <li style="padding: 2px;">Total technical failures: """ + str(
        transfer_report_meta_data['total-technical-failures']) + """</li>
    <li style="padding: 2px;">Total transfers: """ + str(transfer_report_meta_data['total-transfers']) + """</li>
    </ul>
    </body>
    </html>
    """


def _should_skip_email(transfer_report_meta_data, technical_failure_threshold_rate):
    manually_generated_report = transfer_report_meta_data['config-start-datetime'] != 'None'
    daily_report_below_threshold = transfer_report_meta_data['config-cutoff-days'] == 0 and \
                                   transfer_report_meta_data['technical-failures-percentage'] < technical_failure_threshold_rate

    if manually_generated_report or daily_report_below_threshold:
        return True

    return False
