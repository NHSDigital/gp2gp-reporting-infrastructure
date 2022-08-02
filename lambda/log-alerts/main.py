import urllib3
import boto3
import json
import os
import zlib
from datetime import datetime
from base64 import b64decode

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]

def generate_markdown_message(sns_message):
    alarm_name = sns_message['AlarmName']
    state = sns_message['NewStateValue']
    message = sns_message['NewStateReason']
    return f"## **{alarm_name}**\n\nAlarm state: **{state}**\n\n{message}"

def decode(data):
    compressed_payload = b64decode(data)
    json_payload = zlib.decompress(compressed_payload, 16+zlib.MAX_WBITS)
    return json.loads(json_payload)

def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    data = decode(event["awslogs"]["data"])
    message = json.loads(data["logEvents"][0]["message"])
    percent_of_technical_failures = message["percent-of-technical-failures"]
    total_technical_failures = message["total-technical-failures"]
    total_transfers = message["total-transfers"]
    start_date = message["reporting-window-start-datetime"]
    datetime_obj = datetime.strptime(start_date, '%Y-%m-%dT%H:%M:%S%z').strftime("%A %d %B, %Y")

    text = (
        f"## Technical failures are above the threshold. ##\n\n"
        f"* **Percent of technical failures**: {percent_of_technical_failures}%\n\n"
        f"* **Total technical failures**: {total_technical_failures}\n\n"
        f"* **Total transfers**: {total_transfers}\n\n"
        f"* **Date**: {datetime_obj}\n\n"
    )

    msg = {
        "text": text,
        "textFormat": "markdown"
    }

    encoded_msg = json.dumps(msg).encode('utf-8')

    general_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_WEBHOOK_URL_PARAM_NAME"])
    general_alert_resp = http.request('POST', url=general_alert_webhook_url, body=encoded_msg)

    print({
        "message": msg["text"],
        "status_code": general_alert_resp.status,
        "response": general_alert_resp.data,
        "alert_type": "daily_general_technical_failure_rates",
    })

    technical_failure_threshold = secret_manager.get_secret(os.environ["LOG_ALERTS_TECHNICAL_FAILURE_RATE_THRESHOLD"])

    if percent_of_technical_failures > int(technical_failure_threshold):
        exceeded_threshold_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_EXCEEDED_THRESHOLD_WEBHOOK_URL_PARAM_NAME"])
        exceeded_threshold_alert_resp = http.request('POST', url=exceeded_threshold_alert_webhook_url, body=encoded_msg)

        print({
            "message": msg["text"],
            "status_code": exceeded_threshold_alert_resp.status,
            "response": exceeded_threshold_alert_resp.data,
            "alert_type": "exceeded_threshold_technical_failure_rates",
            "technical_failure_threshold": technical_failure_threshold,
            "technical_failure_rate": percent_of_technical_failures
        })