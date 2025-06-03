import os
import tempfile

import boto3
from moto import mock_aws

from main import lambda_handler, get_files_from_S3, list_files_from_S3
from tests.conftest import REGION_NAME, MOCK_BUCKET

def readfile(filename: str) -> str:
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, "r") as file:
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
def test_lambda_handler_returns_200(mock_valid_event_valid_date, context, set_env):
    conn = boto3.resource('s3', region_name=REGION_NAME)
    conn.create_bucket(Bucket=MOCK_BUCKET)

    expected = {'statusCode': 200}

    result = lambda_handler(mock_valid_event_valid_date, context)
    assert result == expected


def test_lambda_handler_calls_S3_with_date_prefix(mock_valid_event_valid_date, context, mocker, set_env):
    mock_function_call = mocker.patch('main.list_files_from_S3')

    lambda_handler(mock_valid_event_valid_date, context)

    mock_function_call.assert_called_with(prefix="2024/01/01", bucket_name=MOCK_BUCKET)


@mock_aws
def test_list_all_files_from_S3():
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    conn = boto3.resource('s3', region_name=REGION_NAME)
    bucket = conn.create_bucket(Bucket=MOCK_BUCKET)

    for file in json_files:
        bucket.upload_file(os.path.join(folder_path, file), f"2024/01/01/{file}")

    files = list_files_from_S3(MOCK_BUCKET, "2024/01/01/")

    assert len(files) == len(json_files)
    for index in range(len(files)):
        assert f"2024/01/01/{json_files[index]}" in files

# @mock_aws
def test_get_files_from_S3_called_with_list_of_files(set_env, mock_valid_event_valid_date, context, mocker):
    mock_get_files_from_S3 = mocker.patch('main.get_files_from_S3')
    mock_list_files_from_S3 = mocker.patch('main.list_files_from_S3')
    mock_list_files_from_S3.return_value = ["2024/01/01/01-DEGRADES-01.json"]
    # folder_path = 'tests/mocks/mixed_messages'
    # json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]
    #
    # conn = boto3.resource('s3', region_name=REGION_NAME)
    # bucket = conn.create_bucket(Bucket=MOCK_BUCKET)
    #
    # for file in json_files:
    #     bucket.upload_file(os.path.join(folder_path, file), f"2024/01/01/{file}")

    lambda_handler(mock_valid_event_valid_date, context)

    mock_get_files_from_S3.assert_called_with(key="2024/01/01/01-DEGRADES-01.json")


@mock_aws
def test_get_files_from_S3_returns_correct_files(set_env, mock_valid_event_valid_date, context, mock_temp_folder):
    folder_path = 'tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    conn = boto3.resource('s3', region_name=REGION_NAME)
    bucket = conn.create_bucket(Bucket=MOCK_BUCKET)

    for file in json_files:
        bucket.upload_file(os.path.join(folder_path, file), f"2024/01/01/{file}")

    files_names = list_files_from_S3(MOCK_BUCKET, "2024/01/01/")

    actual = get_files_from_S3(files_names[0])
    with open("tests/mocks/mixed_messages/01-DEGRADES-01.json", "rb") as expected:
        assert expected.read() == actual