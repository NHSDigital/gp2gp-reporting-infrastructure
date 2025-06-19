import json
import os
import boto3

from degrades_api_dashboards import main

def populate_degrades_table(date):
    bucket = os.getenv("REGISTRATIONS_MI_EVENT_BUCKET")
    s3_client = boto3.client("s3")

    sqs_client = boto3.client("sqs", region_name=os.getenv("REGION"))
    sqs_queue_url = sqs_client.get_queue_url(QueueName=os.getenv("DEGRADES_SQS_QUEUE_NAME"))


    file_keys = main.list_files_from_S3(s3_client, bucket, date)

    for file_key in file_keys:
        message = main.get_file_from_S3(s3_client, file_key)
        message_dict = json.loads(message)
        sqs_client.send_message(QueueUrl=sqs_queue_url["QueueUrl"], MessageBody=json.dumps(message_dict))

