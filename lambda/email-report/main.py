import os.path
import boto3
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from datetime import datetime, timedelta


def lambda_handler(event, context):
    print("Event: ", event)

    FILEOBJ = event["Records"][0]
    BUCKET_NAME = str(FILEOBJ['s3']['bucket']['name'])
    KEY = str(FILEOBJ['s3']['object']['key'])
    FILE_NAME = os.path.basename(KEY)
    TMP_FILE_NAME = '/tmp/' + FILE_NAME

    # Download the file/s from the event (extracted above) to the tmp location
    s3 = boto3.client("s3")
    s3.download_file(BUCKET_NAME, KEY, TMP_FILE_NAME)

    s3_report_object = s3.get_object(Bucket=BUCKET_NAME, Key=KEY)

    transfer_report_meta_data = s3_report_object['Metadata']
    print("Report metadata:", transfer_report_meta_data)

    start_datetime = datetime.strptime(transfer_report_meta_data['reporting-window-start-datetime'], '%Y-%m-%dT%H:%M:%S%z').strftime("%A %d %B, %Y")
    end_datetime = (datetime.strptime(transfer_report_meta_data['reporting-window-end-datetime'], '%Y-%m-%dT%H:%M:%S%z') - timedelta(days=1)).strftime("%A %d %B, %Y")

    BODY_TEXT = "Please see the report attached."
    BODY_HTML = """\
    <html>
    <head></head>
    <body>
    <h1>GP2GP Report</h1>
    <h3>""" + BODY_TEXT + """</h3>
    <ul>
    <li style="padding: 2px;">Technical failures percentage: <strong>""" + str(transfer_report_meta_data['technical-failures-percentage']) + """%</strong></li>
    <li style="padding: 2px;">Start Date: """ + start_datetime + """</li>
    <li style="padding: 2px;">End date: """ + end_datetime + """</li>
    <li style="padding: 2px;">Report Name: """ + str(transfer_report_meta_data['report-name']) + """</li>
    <li style="padding: 2px;">Cutoff: """ + str(transfer_report_meta_data['config-cutoff-days']) + """</li>
    <li style="padding: 2px;">Total technical failures: """ + str(transfer_report_meta_data['total-technical-failures']) + """</li>
    <li style="padding: 2px;">Total transfers: """ + str(transfer_report_meta_data['total-transfers']) + """</li>
    </ul>
    </body>
    </html>
    """
    SUBJECT = "GP2GP Report: " + start_datetime + " - " + end_datetime + " (Technical failures: " + str(transfer_report_meta_data['technical-failures-percentage']) + "%)"
    SENDER = "Firstname Lastname <email@email.com>"
    RECIPIENT = "email@email.com"
    AWS_REGION = "eu-west-2"

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
        client = boto3.client('ses', region_name=AWS_REGION)
        response = client.send_raw_email(
            Source=SENDER,
            Destinations=[
                RECIPIENT
            ],
            RawMessage={
                'Data':msg.as_string(),
            },
            # ConfigurationSetName=CONFIGURATION_SET
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email successfully sent! Message ID:", response['MessageId'])
