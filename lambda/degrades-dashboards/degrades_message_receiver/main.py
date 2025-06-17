import json
import os
import boto3
from datetime import datetime

from models.degrade_message import DegradeMessage

DEGRADES_TABLE = os.getenv("DEGRADES_MESSAGE_TABLE")
REGION = os.getenv("AWS_REGION")


def lambda_handler(event, context):
    sqs_message = json.loads(event["Records"][0]["body"])

    timestamp = int(datetime.fromisoformat(sqs_message["eventGeneratedDateTime"]).timestamp())

    message = DegradeMessage(timestamp=timestamp, message_id=sqs_message["eventId"])
    new_entry = message.model_dump(by_alias=True)
    client = boto3.resource("dynamodb", region_name=os.getenv("AWS_REGION"))
    table = client.Table(os.getenv("DEGRADES_MESSAGE_TABLE"))
    table.put_item(Item=new_entry)