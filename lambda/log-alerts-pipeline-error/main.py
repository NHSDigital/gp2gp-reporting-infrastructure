import logging

import urllib3
import boto3
import json
import os
import requests

from botocore.exceptions import ClientError
from requests import HTTPError

http = urllib3.PoolManager()
logger = logging.getLogger()
logger.setLevel(logging.INFO)


class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):

    try:
        ssm = boto3.client("ssm")
        secret_manager = SsmSecretManager(ssm)

        slack_channel_id = secret_manager.get_secret(os.environ["SLACK_CHANNEL_ID_PARAM_NAME"])
        slack_bot_token = secret_manager.get_secret(os.environ["SLACK_BOT_TOKEN_PARAM_NAME"])

        send_slack_alert(channel_id=slack_channel_id, bot_token=slack_bot_token)

        logger.info("Successfully sent slack alert")

    except ClientError as e:
        logger.error(e)
        logger.error("SSM failure")
    except HTTPError as e:
        logger.error(e)
        logger.error("Failed to send alert")
    except Exception as e:
        logger.error(e)
        logger.error("Unhandled exception raised")


def send_slack_alert(channel_id, bot_token):

    slack_message = {
        "channel": channel_id,
        "blocks": create_slack_message()
    }
    try:
        requests.post(
            url="https://slack.com/api/chat.postMessage",
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {bot_token}"
            },
            data=json.dumps(slack_message),
        )
    except HTTPError as e:
        logger.error(e)
        logger.error("Failed to send slack alert")
    except Exception as e:
        logger.error(e)


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
                "text": f"Check the Cloudwatch dashboard <{cloudwatch_dashboard_url}>"
            }
        }
    ]