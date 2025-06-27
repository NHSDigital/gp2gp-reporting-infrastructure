import os
import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError

class DynamoService:
    def __init__(self):
        self.client = boto3.resource('dynamodb', region_name=os.getenv("REGION"))

    def query(self, key, condition, table_name):
        try:
            table = self.client.Table(table_name)
            results =table.query(KeyConditionExpression=Key(key).eq(condition))
            return results["Items"]
        except ClientError as e:
            print("There has been an error: {}".format(e))
            raise Exception

