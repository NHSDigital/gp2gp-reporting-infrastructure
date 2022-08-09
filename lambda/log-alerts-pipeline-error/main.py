import urllib3
import boto3
import json
import os
import zlib
from base64 import b64decode

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]

def decode(data):
    compressed_payload = b64decode(data)
    json_payload = zlib.decompress(compressed_payload, 16+zlib.MAX_WBITS)
    return json.loads(json_payload)

def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    cloudwatch_dashboard_url = os.environ["CLOUDWATCH_DASHBOARD_URL"]

    text = (
        f"## There was an error in the data pipeline: ##\n\n"
        f"See all the details in cloudwatch: {cloudwatch_dashboard_url}%\n\n"
    )

    msg = {
        "text": text,
        "textFormat": "markdown"
    }
    pipeline_error_encoded_msg = json.dumps(msg).encode('utf-8')

    pipeline_error_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])
    pipeline_error_alert_resp = http.request('POST', url=pipeline_error_alert_webhook_url, body=pipeline_error_encoded_msg)

    print({
        "message": msg["text"],
        "status_code": pipeline_error_alert_resp.status,
        "response": pipeline_error_alert_resp.data,
        "alert_type": "pipeline_error_technical_failure_rates",
    })
