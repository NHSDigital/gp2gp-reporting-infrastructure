import os
import json
import boto3
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(bucket_name, key):
    s3_resource = boto3.resource("s3")

    with open("tmp", "wb") as data:
        s3_resource.Bucket(bucket_name).download_fileobj(key, data)




@validate_date_input
def lambda_handler(event, context):


    file_key = get_key_from_date(event["queryStringParameters"]["date"])
    get_files_from_S3(file_key)

    return {"statusCode": 200}



