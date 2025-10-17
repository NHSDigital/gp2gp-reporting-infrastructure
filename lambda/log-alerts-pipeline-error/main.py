import urllib3
import boto3
import json
import os
import requests

from botocore.exceptions import ClientError

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    cloudwatch_dashboard_url = os.environ["CLOUDWATCH_DASHBOARD_URL"]

    text = (
        f"## **There was an error in the data pipeline:** <br>"
        f"See all the details in cloudwatch: {cloudwatch_dashboard_url}%<br>"
    )

    msg = {
        "text": text,
        "textFormat": "markdown"
    }
    pipeline_error_encoded_msg = json.dumps(msg).encode('utf-8')

    pipeline_error_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])

    slack_channel = secret_manager.get_secret(os.environ["SLACK_CHANNEL_ID_PARAM_NAME"])
    slack_bot_token = secret_manager.get_secret(os.environ["SLACK_BOT_TOKEN_PARAM_NAME"])

    try:
        pipeline_error_alert_resp = http.request('POST', url=pipeline_error_alert_webhook_url, body=pipeline_error_encoded_msg)

        print({
            "message": msg["text"],
            "status_code": pipeline_error_alert_resp.status,
            "response": pipeline_error_alert_resp.data,
            "alert_type": "pipeline_error_technical_failure_rates",
        })

    except ClientError as e:
        print(e.response['Error']['Message'])
    except Exception as e:
        print("An error has occurred: ", e)
    else:
        print("Successfully sent alerts")


def send_slack_alert():
    pass

def create_slack_message():

    cloudwatch_dashboard_url = os.environ["CLOUDWATCH_DASHBOARD_URL"]

    return [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "Data Pipeline Error"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "plain_text",
                "text": f"Check the cloudwatch dashboard <{cloudwatch_dashboard_url}>"
            }
        }
    ]

