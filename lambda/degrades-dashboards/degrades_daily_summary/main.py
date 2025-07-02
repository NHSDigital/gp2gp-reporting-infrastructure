import csv
import json
import os
import logging
from models.degrade_message import DegradeMessage
from utils.dynamo_service import DynamoService
from utils.utils import (
    extract_query_timestamp_from_scheduled_event_trigger,
    get_degrade_totals_from_degrades,
)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Retrieving timestamp and date from event")
    query_timestamp, query_day = extract_query_timestamp_from_scheduled_event_trigger(
        event
    )

    logger.info(f"Querying dynamo for degrades with timestamp: {query_timestamp}")
    dynamo_service = DynamoService()
    degrades = dynamo_service.query(
        key="Timestamp",
        condition=query_timestamp,
        table=os.getenv("DEGRADES_MESSAGE_TABLE"),
    )

    logger.info(f"Generating report for {query_day}")
    generate_report_from_dynamo_query(degrades, query_day)


def generate_report_from_dynamo_query(
    degrades_from_table: list[dict], date: str
) -> None:
    degrades = [DegradeMessage(**message) for message in degrades_from_table]

    logger.info(f"Getting degrades totals from: {degrades}")
    degrade_totals = get_degrade_totals_from_degrades(degrades)

    logger.info(f"Writing degrades report...")
    with open(f"{os.getcwd()}/tmp/{date}.csv", "w") as output_file:
        writer = csv.writer(output_file)
        for key, value in degrade_totals.items():
            writer.writerow([key, value])
