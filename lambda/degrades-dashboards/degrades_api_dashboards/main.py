import os
import json
from utils.decorators import validate_date_input
from utils.utils import get_key_from_date, is_degrade
from utils.s3_service import S3Service


def calculate_number_of_degrades(date):
    service = S3Service()
    number_of_degrades_from_date = 0
    file_names = service.list_files_from_S3(
        prefix=date, bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET")
    )
    for file_name in file_names:
        file = service.get_file_from_S3(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"), key=file_name
        )
        if is_degrade(file):
            number_of_degrades_from_date += 1

    return number_of_degrades_from_date


@validate_date_input
def lambda_handler(event, context):
    prefix = get_key_from_date(event["queryStringParameters"]["date"])

    number_of_degrades = calculate_number_of_degrades(date=prefix)

    return {
        "statusCode": 200,
        "body": json.dumps({"numberOfDegrades": number_of_degrades}),
    }
