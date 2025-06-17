import boto3
import json
from datetime import datetime
from moto import mock_aws
from degrades_message_receiver.main import lambda_handler
from tests.conftest import REGION_NAME, MOCK_DEGRADES_MESSAGE_TABLE_NAME, MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA, \
    MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES, MOCK_VALID_DEGRADES_MESSAGE


@mock_aws
def test_degrades_message_receiver_puts_item_on_table(set_env, context):
    conn = boto3.resource("dynamodb", region_name=REGION_NAME)
    degrades_table = conn.create_table(TableName=MOCK_DEGRADES_MESSAGE_TABLE_NAME,
                                       KeySchema=MOCK_DEGRADES_MESSAGE_TABLE_KEY_SCHEMA,
                                       AttributeDefinitions=MOCK_DEGRADES_MESSAGE_TABLE_ATTRIBUTES,
                                       BillingMode="PAY_PER_REQUEST", )

    event = {"Records": [{"body": json.dumps(MOCK_VALID_DEGRADES_MESSAGE)}]}

    lambda_handler(event, context)
    timestamp = int(datetime.fromisoformat(MOCK_VALID_DEGRADES_MESSAGE["eventGeneratedDateTime"]).timestamp())

    actual = degrades_table.get_item(Key={"Timestamp": timestamp,
                                          "MessageID": MOCK_VALID_DEGRADES_MESSAGE["eventId"]})
    assert actual["Item"] == MOCK_VALID_DEGRADES_MESSAGE
