import os
import json
from datetime import datetime
from utils.decorators import validate_date_input

def calculate_number_of_degrades(path: str, files: list[str]) -> int:
    total = 0

    for file_name in files:
        file_path = os.path.join(path, file_name)
        with open(file_path, "r") as json_file:
            data = json.load(json_file)
            eventType = data.get("eventType", None)
            if eventType is not None and eventType == "DEGRADES":
                total += 1
    return total

def get_files_from_S3():
    pass

@validate_date_input
def lambda_handler(event, context):

    return {"statusCode": 200}



