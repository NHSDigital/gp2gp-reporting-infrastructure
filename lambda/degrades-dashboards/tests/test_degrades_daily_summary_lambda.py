import os
from moto import mock_aws
from degrades_daily_summary.main import lambda_handler, generate_report_from_dynamo_query
from tests.conftest import TEST_DEGRADES_DATE
from tests.mocks.dynamo_response.degrade_table import simple_message_timestamp
from tests.test_degrade_api_lambda import readfile
from boto3.dynamodb.conditions import Key

@mock_aws
def test_degrades_daily_summary_lambda_queries_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):

    lambda_handler(mock_scheduled_event, context)
    mock_dynamo_service.query.assert_called()
    os.remove(f"{os.getcwd()}/tmp/{TEST_DEGRADES_DATE}.csv")


@mock_aws
def test_degrades_daily_summary_uses_trigger_date_to_query_dynamo(set_env, context, mock_dynamo_service, mock_table, mock_scheduled_event):

    lambda_handler(mock_scheduled_event, context)
    mock_dynamo_service.query.assert_called_with(key="Timestamp", condition=simple_message_timestamp, table=mock_table.table_name)
    os.remove(f"{os.getcwd()}/tmp/{TEST_DEGRADES_DATE}.csv")



@mock_aws
def test_generate_report_from_dynamo_query_result(mock_table_with_files):
    degrades_from_table = mock_table_with_files.query(KeyConditionExpression=Key("Timestamp").eq(simple_message_timestamp))["Items"]

    generate_report_from_dynamo_query(degrades_from_table, TEST_DEGRADES_DATE)

    expected = readfile(f"{os.getcwd()}/tests/reports/{TEST_DEGRADES_DATE}.csv")
    with open(f"{os.getcwd()}/tmp/{TEST_DEGRADES_DATE}.csv", "r") as file:
        actual = file.read()
        assert actual == expected
    os.remove(f"{os.getcwd()}/tmp/{TEST_DEGRADES_DATE}.csv")


@mock_aws
def test_degrades_daily_summary_generates_report(mock_scheduled_event, context, set_env, mocker, mock_table_with_files):
    mock_generate_report = mocker.patch("degrades_daily_summary.main.generate_report_from_dynamo_query")

    degrades = mock_table_with_files.query(KeyConditionExpression=Key("Timestamp").eq(simple_message_timestamp))["Items"]

    lambda_handler(mock_scheduled_event, context)

    mock_generate_report.assert_called_with(degrades, TEST_DEGRADES_DATE)




#  TODO PRM-366 test degrades daily summary uploads to S3