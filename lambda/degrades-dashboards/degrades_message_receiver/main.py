import json
import os
import boto3
import logging
from datetime import datetime
from pydantic import ValidationError
from models.degrade_message import DegradeMessage
from utils.utils import extract_degrades_payload

logger = logging.getLogger()
logger.setLevel("INFO")

def lambda_handler(event, context):
    messages = event.get("Records", [])
    client = boto3.resource("dynamodb", region_name=os.getenv("REGION"))
    table = client.Table(os.getenv("DEGRADES_MESSAGE_TABLE"))

    for message in messages:
        try:
            message = json.loads(message["body"])

            if message["eventType"] != "DEGRADES":
                logger.info("Validation error: Message is not of type DEGRADES")
                raise ValueError("Invalid degrade message")

            timestamp = int(datetime.fromisoformat(message["eventGeneratedDateTime"]).timestamp())

            degrades = extract_degrades_payload(message["payload"])

            degrades_message = DegradeMessage(timestamp=timestamp, message_id=message["eventId"], event_type=message["eventType"], degrades=degrades)
            DegradeMessage.model_validate(degrades_message)


            table.put_item(Item=degrades_message.model_dump(by_alias=True, exclude={"event_type"}))
            logger.info("Degrade successfully added to table.")
        except ValidationError as e:
            logger.info("Validation error: Invalid degrade message")
            raise ValueError("Invalid degrade message", e.json)
        except Exception as e:
            logger.info(e)
