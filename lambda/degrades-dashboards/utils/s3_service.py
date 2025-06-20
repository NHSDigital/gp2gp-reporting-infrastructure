import boto3
import os
from botocore.exceptions import ClientError


class S3Service:
    _instance = None
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.initialised = False
        return cls._instance

    def __init__(self):
        if not self.initialised:
         self.client = boto3.client("s3", region_name=os.getenv("REGION"))

    def list_files_from_S3(self, bucket_name, prefix):

        response = self.client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        file_keys = []
        response_objects = response.get("Contents", [])

        if response_objects:
            for obj in response_objects:
                file_keys.append(obj["Key"])

        return file_keys


    def get_file_from_S3(self, bucket_name, key):
        response = self.client.get_object(Bucket=bucket_name, Key=key)
        return response["Body"].read()
