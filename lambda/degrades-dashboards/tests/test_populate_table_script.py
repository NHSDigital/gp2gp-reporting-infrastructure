import os
from unittest.mock import Mock, patch

import pytest

import degrades_api_dashboards
from scripts.populate_table import populate_degrades_table
from tests.conftest import MOCK_BUCKET
import degrades_api_dashboards.main
from moto import mock_aws
import boto3

test_date = "2024/01/01"

@pytest.fixture
def mock_list_files_from_S3(mocker):
    return mocker.patch.object(degrades_api_dashboards.main, "list_files_from_S3")

@pytest.fixture()
def mock_get_file_from_S3(mocker):
    return mocker.patch.object(degrades_api_dashboards.main, "get_file_from_S3")

@pytest.fixture()
def mock_s3(mocker):
    return mocker.patch("boto3.client")


def test_populate_table_script_lists_files_from_S3(set_env, mock_list_files_from_S3, mock_s3):
    client = boto3.client("s3")
    populate_degrades_table(test_date)

    mock_list_files_from_S3.assert_called_with(client, MOCK_BUCKET, test_date)


@mock_aws
def test_populate_table_script_gets_all_files_from_S3(set_env, mock_list_files_from_S3, mock_get_file_from_S3, mock_s3):
    mock_list_files_from_S3.return_value = ["testing"]
    populate_degrades_table(test_date)
    mock_get_file_from_S3.assert_called()
