import os
import json

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

    """
    Get objs from bucket with date
    Read objs
    Calculate number of degrades, split degrades by type
    Return number of degrades

    """
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
