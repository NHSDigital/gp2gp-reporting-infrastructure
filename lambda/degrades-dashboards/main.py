import os
import json
import boto3
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(key):
    print(key)
    return [1,2,3,4,5,6,7]

@validate_date_input
def lambda_handler(event, context):


    file_key = get_key_from_date(event["queryStringParameters"]["date"])
    get_files_from_S3(file_key)

    return {"statusCode": 200}



