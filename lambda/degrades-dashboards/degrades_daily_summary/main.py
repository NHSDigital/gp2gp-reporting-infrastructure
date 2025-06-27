import os
import boto3
from boto3.dynamodb.conditions import Key


def lambda_handler(event, context):
    client = boto3.resource("dynamodb", region_name=os.getenv("REGION"))
    table = client.Table(os.getenv("DEGRADES_MESSAGE_TABLE"))

    results = table.query(KeyConditionExpression=Key("Timestamp").eq(1))
    return results["Items"]