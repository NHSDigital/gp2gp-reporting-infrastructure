import os
import json
from sys import prefix

import boto3
import os
import tempfile
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(key):
    s3_client = boto3.client("s3")
    response = s3_client.get_object(Bucket=os.getenv("BUCKET_NAME"), Key=key)
    return response["Body"].read()


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

    file_names = list_files_from_S3(prefix=prefix, bucket_name=os.getenv("BUCKET_NAME"))
    for file_name in file_names:
        get_files_from_S3(key=file_name)

    return {"statusCode": 200}



