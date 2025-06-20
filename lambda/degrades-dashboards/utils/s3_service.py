import boto3
import os


class S3Service:
    def __init__(self):
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
        pass