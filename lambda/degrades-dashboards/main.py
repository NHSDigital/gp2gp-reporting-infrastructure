import boto3
import os
import json
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date, is_degrade


def get_file_from_S3(key):
    s3_client = boto3.client("s3")
    response = s3_client.get_object(Bucket=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"), Key=key)
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


def calculate_number_of_degrades(date):

    number_of_degrades_from_date = 0
    file_names = list_files_from_S3(prefix=date, bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"))
    for file_name in file_names:
        file = get_file_from_S3(key=file_name)
        if is_degrade(file):
            number_of_degrades_from_date += 1

    return number_of_degrades_from_date



@validate_date_input
def lambda_handler(event, context):

    prefix = get_key_from_date(event["queryStringParameters"]["date"])

    number_of_degrades = calculate_number_of_degrades(date=prefix)

    return {"statusCode": 200, "body": json.dumps({"numberOfDegrades": number_of_degrades})}
