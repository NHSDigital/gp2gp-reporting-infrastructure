import csv
import os

from models.degrade_message import DegradeMessage
from utils.dynamo_service import DynamoService
from utils.utils import extract_query_timestamp_from_scheduled_event_trigger, get_degrade_totals_from_degrades

def lambda_handler(event, context):
    query_timestamp, query_day = extract_query_timestamp_from_scheduled_event_trigger(event)
    dynamo_service = DynamoService()
    degrades = dynamo_service.query(key="Timestamp", condition=query_timestamp, table=os.getenv("DEGRADES_MESSAGE_TABLE"))
    generate_report_from_dynamo_query(degrades, query_day)

def generate_report_from_dynamo_query(degrades_from_table: list[dict], date: str) -> None:
    degrades = [DegradeMessage(**message) for message in degrades_from_table]

    degrade_totals = get_degrade_totals_from_degrades(degrades)

    with open(f"{os.getcwd()}/tmp/{date}.csv", "w") as output_file:
        writer = csv.writer(output_file)
        for key, value in degrade_totals.items():
            writer.writerow([key, value])
