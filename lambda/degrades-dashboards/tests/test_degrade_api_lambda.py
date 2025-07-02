import json
import os
import boto3
from moto import mock_aws

from degrades_api_dashboards.main import lambda_handler, calculate_number_of_degrades
from tests.conftest import REGION_NAME, MOCK_BUCKET

def readfile(filename: str) -> str:
    with open(filename, "r") as file:
        file_content = file.read()
    return file_content

def test_lambda_handler_throws_400_no_query_string(mock_invalid_event_empty_query_string, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_empty_query_string, context)
    assert result == expected


def test_lamda_handler_throws_400_no_date_in_query_string(mock_invalid_event_without_date, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_without_date, context)
    assert result == expected


def test_lamda_handler_throws_400_invalid_date_format_in_query_string(mock_invalid_event_invalid_date_format, context):
    expected = {'statusCode': 400}

    result = lambda_handler(mock_invalid_event_invalid_date_format, context)
    assert result == expected

@mock_aws
def test_lambda_handler_calls_S3_with_date_prefix(mock_valid_event_valid_date, context, set_env, mock_s3_service, mock_s3_with_files):
    lambda_handler(mock_valid_event_valid_date, context)

    mock_s3_service.list_files_from_S3.assert_called_with(prefix="2024/01/01", bucket_name=MOCK_BUCKET)

def test_get_files_from_S3_called_with_list_of_files(set_env, mock_valid_event_valid_date, context, mock_s3_service, mock_s3_with_files):
    mock_s3_service.list_files_from_S3.return_value = ["2024/01/01/01-DEGRADES-01.json"]
    mock_s3_service.get_file_from_S3.return_value = readfile("tests/mocks/mixed_messages/01-DEGRADES-01.json")

    lambda_handler(mock_valid_event_valid_date, context)

    mock_s3_service.get_file_from_S3.assert_called_with(bucket_name=MOCK_BUCKET, key="2024/01/01/01-DEGRADES-01.json")

@mock_aws
def test_lambda_handler_calculates_number_of_degrades(set_env, mock_valid_event_valid_date, context, mock_s3_with_files):
    expected = {'statusCode': 200, "body": json.dumps({"numberOfDegrades": 5})}
    actual = lambda_handler(mock_valid_event_valid_date, context)

    assert actual == expected
    assert calculate_number_of_degrades("2024/01/01") == json.loads(expected["body"])["numberOfDegrades"]