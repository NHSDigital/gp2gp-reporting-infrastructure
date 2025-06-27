import os

from models.degrade_message import DegradeMessage
from utils.dynamo_service import DynamoService
from utils.utils import extract_query_timestamp_from_scheduled_event_trigger

def lambda_handler(event, context):
    query_timestamp = extract_query_timestamp_from_scheduled_event_trigger(event)
    dynamo_service = DynamoService()
    dynamo_service.query(key="Timestamp", condition=query_timestamp, table=os.getenv("DEGRADES_MESSAGE_TABLE"))


def generate_report_from_dynamo_query(degrades_from_table: list[dict]) -> None:
    degrades = [DegradeMessage(**message) for message in degrades_from_table]

    degrade_totals = {}

    for degrade in degrades:
        for degrade_type in degrade.degrades:
            if degrade_totals.get(degrade_type):
                degrade_totals[degrade_type] += 1
            else:
                degrade_totals[degrade_type] = 1