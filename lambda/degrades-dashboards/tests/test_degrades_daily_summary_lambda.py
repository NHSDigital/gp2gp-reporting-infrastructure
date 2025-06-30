import os
from datetime import datetime

from moto import mock_aws
from degrades_daily_summary.main import lambda_handler, generate_report_from_dynamo_query
from models.degrade_message import DegradeMessage
from tests.mocks.dynamo_response.degrade_table import simple_message_timestamp
from tests.mocks.sqs_messages.degrades import MOCK_COMPLEX_DEGRADES_MESSAGE, MOCK_FIRST_DEGRADES_MESSAGE, \
    MOCK_SIMPLE_DEGRADES_MESSAGE
from tests.test_degrade_api_lambda import readfile
from utils.utils import extract_degrades_payload

from boto3.dynamodb.conditions import Key

@mock_aws
def test_degrades_daily_summary_lambda_queries_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):

    lambda_handler(mock_scheduled_event, context)
    mock_dynamo_service.query.assert_called()


@mock_aws
def test_degrades_daily_summary_uses_trigger_date_to_query_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):

    lambda_handler(mock_scheduled_event, context)
    mock_dynamo_service.query.assert_called_with(key="Timestamp", condition=simple_message_timestamp, table=mock_table.table_name)


@mock_aws
def test_generate_report_from_dynamo_query_result(mock_table_with_files):

    degrades_from_table = mock_table_with_files.query(KeyConditionExpression=Key("Timestamp").eq(simple_message_timestamp))["Items"]

    generate_report_from_dynamo_query(degrades_from_table, "2024-09-20")
    # TODO remember to add "tests/" back into file path for pytest to work from terminal.
    expected = readfile(f"{os.getcwd()}/tests/reports/2024-09-20.csv")
    with open(f"{os.getcwd()}/tmp/2024-09-20.csv", "r") as file:
        actual = file.read()
        assert actual == expected
    os.remove(f"{os.getcwd()}/tmp/2024-09-20.csv")



# TODO add test to ensure lambda calls generate report.
