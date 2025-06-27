import os
from utils.dynamo_service import DynamoService
from utils.utils import extract_query_timpstamp_from_scheduled_event_trigger

def lambda_handler(event, context):
    query_timestamp = extract_query_timpstamp_from_scheduled_event_trigger(event)
    dynamo_service = DynamoService()
    dynamo_service.query(key="Timestamp", condition=query_timestamp, table=os.getenv("DEGRADES_MESSAGE_TABLE"))
