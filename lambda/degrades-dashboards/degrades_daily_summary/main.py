import os
from utils.dynamo_service import DynamoService


def lambda_handler(event, context):
    dynamo_service = DynamoService()
    dynamo_service.query("Timestamp", 1, os.getenv("DEGRADES_MESSAGE_TABLE"))
