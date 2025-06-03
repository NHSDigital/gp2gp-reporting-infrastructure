import json
import os

def get_key_from_date(date: str):
    return date.replace("-", "/")

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

def is_degrade(file) -> bool:
    data = json.load(file)
    eventType = data.get("eventType", None)
    return eventType is not None and eventType == "DEGRADES"