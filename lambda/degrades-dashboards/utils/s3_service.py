import boto3
import os
from botocore.exceptions import ClientError


class S3Service:
    def __init__(self):
        try:
            self.client = boto3.client("s3", region_name=os.getenv("REGION"))
        except ClientError as e:
            raise e

    def list_files_from_S3(self, bucket_name, prefix):
        try:
            response = self.client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
            file_keys = []
            response_objects = response.get("Contents", [])

            if response_objects:
                for obj in response_objects:
                    file_keys.append(obj["Key"])

            return file_keys

        except ClientError as e:
            print(f"There was an error listing files from S3: {e}")
            raise Exception("There was an error listing files from S3")



    def get_file_from_S3(self, bucket_name, key):
        pass