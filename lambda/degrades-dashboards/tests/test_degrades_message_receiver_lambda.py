import boto3
import json
from datetime import datetime
from moto import mock_aws
from degrades_message_receiver.main import lambda_handler
from tests.conftest import REGION_NAME, MOCK_DEGRADES_MESSAGE_TABLE_NAME, MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA, \
    MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES, MOCK_FIRST_DEGRADES_MESSAGE, MOCK_SECOND_DEGRADES_MESSAGE

from models.degrade_message import DegradeMessage


@mock_aws
def test_degrades_message_receiver_handles_single_message(set_env, context):
    conn = boto3.resource("dynamodb", region_name=REGION_NAME)
    degrades_table = conn.create_table(TableName=MOCK_DEGRADES_MESSAGE_TABLE_NAME,
                                       KeySchema=MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA,
                                       AttributeDefinitions=MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES,
                                       BillingMode="PAY_PER_REQUEST", )

    event = {"Records": [{"body": json.dumps(MOCK_FIRST_DEGRADES_MESSAGE)}]}

    lambda_handler(event, context)
    timestamp = int(datetime.fromisoformat(MOCK_FIRST_DEGRADES_MESSAGE["eventGeneratedDateTime"]).timestamp())

    actual = degrades_table.get_item(Key={"Timestamp": timestamp,
                                          "MessageId": MOCK_FIRST_DEGRADES_MESSAGE["eventId"]})

    assert (DegradeMessage.model_validate(actual["Item"]) == DegradeMessage.model_validate(
        {"timestamp": timestamp, "message_id": MOCK_FIRST_DEGRADES_MESSAGE["eventId"]}))


@mock_aws
def test_degrades_message_receiver_handles_more_than_one_message(set_env, context):
    conn = boto3.resource("dynamodb", region_name=REGION_NAME)
    degrades_table = conn.create_table(TableName=MOCK_DEGRADES_MESSAGE_TABLE_NAME,
                                       KeySchema=MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA,
                                       AttributeDefinitions=MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES,
                                       BillingMode="PAY_PER_REQUEST", )

    event = {"Records": [{"body": json.dumps(MOCK_FIRST_DEGRADES_MESSAGE)}, {"body": json.dumps(MOCK_SECOND_DEGRADES_MESSAGE)}]}

    lambda_handler(event, context)
    response = degrades_table.scan()

    assert len(response["Items"]) == 2
