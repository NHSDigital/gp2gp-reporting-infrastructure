import json
import os
import boto3
from datetime import datetime

from pydantic_core._pydantic_core import ValidationError

from models.degrade_message import DegradeMessage
from utils.utils import extract_degrades_payload

DEGRADES_TABLE = os.getenv("DEGRADES_MESSAGE_TABLE")
REGION = os.getenv("AWS_REGION")


def lambda_handler(event, context):
    messages = event.get("Records", [])
    client = boto3.resource("dynamodb", region_name=os.getenv("AWS_REGION"))
    table = client.Table(os.getenv("DEGRADES_MESSAGE_TABLE"))

    for message in messages:
        try:
            message = json.loads(message["body"])

            if message["eventType"] != "DEGRADES":
                print("Validation error: Message is not of type DEGRADES")
                raise ValueError("Invalid degrade message")

            timestamp = int(datetime.fromisoformat(message["eventGeneratedDateTime"]).timestamp())

            degrades = extract_degrades_payload(message["payload"])

            degrades_message = DegradeMessage(timestamp=timestamp, message_id=message["eventId"], event_type=message["eventType"], degrades=degrades)
            DegradeMessage.model_validate(degrades_message)

            table.put_item(Item=degrades_message.model_dump(by_alias=True, exclude={"event_type"}))
        except ValidationError as e:
            print("Validation error: Invalid degrade message")
            raise ValueError("Invalid degrade message", e.json)
