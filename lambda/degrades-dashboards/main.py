import os
import json
from sys import prefix

import boto3
import os
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(key):
    pass
    s3_resource = boto3.resource("s3")

    # with open("tests/tmp/", "wb") as data:
    #     s3_resource.Bucket(bucket_name).download_fileobj(key, data)


def list_files_from_S3(bucket_name, prefix):
    client = boto3.client("s3")
    response = client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    file_keys = []
    response_objects = response.get("Contents", [])

    if response_objects:
        for obj in response_objects:
            file_keys.append(obj["Key"])

    return file_keys

@validate_date_input
def lambda_handler(event, context):

    prefix = get_key_from_date(event["queryStringParameters"]["date"])

    list_files_from_S3(prefix=prefix, bucket_name=os.getenv("BUCKET_NAME"))

    return {"statusCode": 200}



