import json
import os
import boto3
from datetime import datetime

from models.degrade_message import DegradeMessage

DEGRADES_TABLE = os.getenv("DEGRADES_MESSAGE_TABLE")
REGION = os.getenv("AWS_REGION")


def lambda_handler(event, context):
    messages = event.get("Records", [])
    client = boto3.resource("dynamodb", region_name=os.getenv("AWS_REGION"))
    table = client.Table(os.getenv("DEGRADES_MESSAGE_TABLE"))

    for message in messages:
        message = json.loads(message["body"])
        timestamp = int(datetime.fromisoformat(message["eventGeneratedDateTime"]).timestamp())

        degrades_message = DegradeMessage(timestamp=timestamp, message_id=message["eventId"], event_type=message["eventType"])
        DegradeMessage.model_validate(degrades_message)


        table.put_item(Item=degrades_message.model_dump(by_alias=True, exclude={"event_type": degrades_message.event_type}))