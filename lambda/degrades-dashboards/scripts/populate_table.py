import os
import boto3

from degrades_api_dashboards import main

def populate_degrades_table(date):
    bucket = os.getenv("REGISTRATIONS_MI_EVENT_BUCKET")
    client = boto3.client("s3")

    file_keys = main.list_files_from_S3(client, bucket, date)

    for file_key in file_keys:
        main.get_file_from_S3(client, file_key)

