import json
import os
import boto3
from datetime import datetime
DEGRADES_TABLE = os.getenv("DEGRADES_MESSAGE_TABLE")
REGION = os.getenv("AWS_REGION")


def lambda_handler(event, context):
    message = json.loads(event["Records"][0]["body"])

    timestamp = int(datetime.fromisoformat(message["eventGeneratedDateTime"]).timestamp())

    client = boto3.client("dynamodb", region_name=os.getenv("AWS_REGION"))
    client.put_item(TableName=os.getenv("DEGRADES_MESSAGE_TABLE"), Item={"MessageID": {"S": message["eventId"]},
                                                                         "Timestamp": {"N": f"{timestamp}"}})
