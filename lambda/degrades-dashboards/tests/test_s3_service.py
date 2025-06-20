import pytest
from moto import mock_aws
import os
from botocore.exceptions import ClientError
from utils.s3_service import S3Service

from tests.conftest import REGION_NAME, MOCK_BUCKET

@pytest.fixture
def mock_s3_service(mocker):
    with mock_aws():
        mocker.patch("utils.s3_service.S3Service.list_files_from_S3")
        service = S3Service()
        return service



@mock_aws
def test_service_list_files_from_S3(set_env, mock_s3_with_files):
    folder_path = './tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    service = S3Service()

    files = service.list_files_from_S3(MOCK_BUCKET, "2024/01/01/")

    assert len(files) == len(json_files)
    for index in range(len(files)):
        assert f"2024/01/01/{json_files[index]}" in files

@mock_aws
def test_list_files_from_S3_raises_error_client_issue(set_env, mock_s3_with_files, mock_s3_service, caplog):
    expected_message = "There was an error listing files from S3"
    mock_s3_service.list_files_from_S3.side_effect = ClientError

    with pytest.raises(Exception):
        mock_s3_service.list_files_from_S3("test", "prefix")
        assert expected_message in caplog.records[-1].msg

@mock_aws
def test_get_file_from_S3(set_env, mock_s3_with_files):
    service = S3Service()
    files_names = service.list_files_from_S3(bucket_name=MOCK_BUCKET, prefix="2024/01/01/")

    actual = service.get_file_from_S3(bucket_name=MOCK_BUCKET, key=files_names[0])
    with open("./tests/mocks/mixed_messages/01-DEGRADES-01.json", "rb") as expected:
        assert expected.read() == actual

