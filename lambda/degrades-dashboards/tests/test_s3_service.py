from moto import mock_aws
import os
import boto3
from utils.s3_service import S3Service

from tests.conftest import REGION_NAME, MOCK_BUCKET


@mock_aws
def test_service_list_files_from_S3(set_env, mock_s3_with_files):
    folder_path = './tests/mocks/mixed_messages'
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    service = S3Service()

    files = service.list_files_from_S3(MOCK_BUCKET, "2024/01/01/")

    assert len(files) == len(json_files)
    for index in range(len(files)):
        assert f"2024/01/01/{json_files[index]}" in files