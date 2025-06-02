import os
import json
from _datetime import datetime

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

def lambda_handler(event, context):

    try:
        params = event.get("queryStringParameters", None)
        if not params:
            return {"statusCode": 400}

        string_date = params.get("date", None)
        if not string_date:
            return {"statusCode": 400}

        date = datetime.strptime(string_date, "%Y-%m-%d").date()

    except ValueError:
        return {"statusCode": 400}




    return 'Hello World!'

"""
TODO: create tests with event that contains a date query string for handler,
    mock out events with and without querystring
"""