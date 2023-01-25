import json
import logging
import os
from datetime import datetime, timedelta

import boto3
import urllib3

http = urllib3.PoolManager()

MINIMUM_NUMBER_OF_EXPECTED_TRANSFERS_THRESHOLD = 150_000


class UnableToFetchObjectFromS3(RuntimeError):
    pass


class UnableToFetchSSMParameter(RuntimeError):
    pass


class InvalidMetrics(RuntimeError):
    pass


class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    try:
        print("Fetching objects from S3...")
        practice_metrics, national_metrics = fetch_metrics_from_s3()
    except UnableToFetchObjectFromS3 as exception:
        logging.error("Failed to fetch objects from S3. " + str(exception))
        raise exception
    try:
        validate_metrics(practice_metrics, national_metrics)
    except InvalidMetrics as exception:
        logging.error("Invalid metrics: " + str(exception))
        raise exception
    print("Metrics validation successful.")


def validate_metrics(practice_metrics, national_metrics):
    return _is_valid_practice_metrics(practice_metrics) and _is_valid_national_metrics(national_metrics)


def _is_valid_practice_metrics(practice_metrics):
    practice_metrics_json = json.loads(practice_metrics)
    list_of_sicbls = practice_metrics_json["sicbls"]
    list_of_practices = practice_metrics_json["practices"]

    # Check there is at least one instance of SICBLs and contains practices in practiceMetrics
    if len(list_of_sicbls[0]['practices']) < 1 or list_of_sicbls[0]['practices'][0] == "":
        raise InvalidMetrics(
            "Invalid practice metrics: sicbl " + json.dumps(list_of_sicbls[0]) + " instance does not contain a "
                                                                                 "practice")

    # Check at least one practice exists with an ODS code and 6 months worth of metrics, including the latest month.
    if list_of_practices[0]["odsCode"] == "" or len(list_of_practices[0]["metrics"]) < 6:
        raise InvalidMetrics("Invalid national metrics: a practice " + list_of_practices[
            0] + " does not contain 6 months worth of metrics OR it does not contain an ODS Code")

    return True


def _is_valid_national_metrics(national_metrics):
    national_metrics_json = json.loads(national_metrics)
    print("National metrics data for a month", national_metrics_json["metrics"][0])
    transfer_count = national_metrics_json["metrics"][0]["transferCount"]
    print("National metrics total transfer count: " + str(transfer_count))
    month = national_metrics_json["metrics"][0]["month"]
    # take the month when data was generated and subtract one to obtain the previous month
    date_when_generated = national_metrics_json["generatedOn"][:10]
    print("National metrics generated on date " + date_when_generated)
    datetime_when_generated = datetime.strptime(date_when_generated, '%Y-%m-%d')
    last_month = datetime_when_generated.replace(day=1) - timedelta(days=1)

    if transfer_count < MINIMUM_NUMBER_OF_EXPECTED_TRANSFERS_THRESHOLD or month != last_month.month:
        raise InvalidMetrics(
            f"Invalid national metrics: the transfer count is smaller than 150 000 or the month (represented as a "
            f"number) of {month} is incorrect.")
    return True


def fetch_metrics_from_s3():
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)
    s3 = boto3.client("s3")
    try:
        print("Fetching s3_file_name_practice_metrics from ssm parameters:")
        s3_file_name_practice_metrics = secret_manager.get_secret(os.environ["S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME"])
        print("Fetching s3_file_name_national_metrics from ssm parameters:")
        s3_file_name_national_metrics = secret_manager.get_secret(os.environ["S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME"])
    except Exception as e:
        print("Unable to fetch SSM Parameter", e)
        raise UnableToFetchSSMParameter

    bucket = os.environ["S3_METRICS_BUCKET_NAME"]
    version = os.environ["S3_METRICS_VERSION"]
    key_practice = version + "/" + s3_file_name_practice_metrics
    key_national = version + "/" + s3_file_name_national_metrics

    try:
        print("Fetching practice metrics from s3 with: ", {"bucket": bucket, "key": key_practice})
        practice_response = s3.get_object(
            Bucket=bucket,
            Key=key_practice)
        print("Successfully fetched practice metrics from s3 with: ", {"bucket": bucket, "key": key_practice})
        practice_metrics_body = practice_response["Body"].read().decode()

        print("Fetching national metrics from s3 with: ", {"bucket": bucket, "key": key_national})
        national_response = s3.get_object(
            Bucket=bucket,
            Key=key_national)
        print("Successfully fetched national metrics from s3 with: ", {"bucket": bucket, "key": key_national})
        national_metrics_body = national_response["Body"].read().decode()
        return [practice_metrics_body, national_metrics_body]
    except Exception as e:
        print("Unable to fetch metrics from s3: ", e)
        raise UnableToFetchObjectFromS3()

