import os
import json
from datetime import datetime
from utils.decorators import validate_date_input
from utils.utils import  get_key_from_date


def get_files_from_S3(key):
    print(key)

@validate_date_input
def lambda_handler(event, context):


    file_key = get_key_from_date(event["queryStringParameters"]["date"])
    get_files_from_S3(file_key)

    return {"statusCode": 200}



