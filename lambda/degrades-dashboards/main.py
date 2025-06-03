import os
import json
import boto3
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(key):
    pass
    s3_resource = boto3.resource("s3")

    # with open("tests/tmp/", "wb") as data:
    #     s3_resource.Bucket(bucket_name).download_fileobj(key, data)


def list_files_from_S3(bucket_name, key):
    client = boto3.client("s3")
    response = client.list_objects_v2(Bucket=bucket_name, Prefix=key)
    file_keys = []
    for obj in response["Contents"]:
        file_keys.append(obj["Key"])

    return file_keys

@validate_date_input
def lambda_handler(event, context):


    file_key = get_key_from_date(event["queryStringParameters"]["date"])
    get_files_from_S3(key=file_key)

    return {"statusCode": 200}



