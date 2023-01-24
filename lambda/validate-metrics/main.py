import json
import logging
import os
from datetime import datetime, timedelta

import boto3
import urllib3

http = urllib3.PoolManager()


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
        practice_metrics, national_metrics = _fetch_objects_from_s3()
    except UnableToFetchObjectFromS3 as exception:
        logging.error("Failed to fetch objects from S3. " + str(exception))
        raise exception
    try:
        _validate_metrics(practice_metrics, national_metrics)
    except InvalidMetrics as exception:
        logging.error("Invalid metrics: " + str(exception))
        raise exception
    logging.info("Metrics validation successful.")


def _validate_metrics(practice_metrics, national_metrics):
    return _validate_practice_metrics(practice_metrics) and _validate_national_metrics(national_metrics)


def _validate_practice_metrics(practice_metrics):
    practice_metrics_json = json.loads(practice_metrics)
    list_of_sicbls = practice_metrics_json["sicbls"]
    list_of_practices = practice_metrics_json["practices"]

    # Check one instance of SICBLs in practiceMetrics.json contains > 0 practice ODS codes - larger than 0?
    if len(list_of_sicbls[0]['practices']) < 1 or list_of_sicbls[0]['practices'][0] == "":
        raise InvalidMetrics(
            "Invalid practice metrics: sicbl " + json.dumps(list_of_sicbls[0]) + " instance does not contain a "
                                                                                 "practice")

    # Check at least once practice exists with an ODS code and 6 months worth of metrics, including the latest month.
    if list_of_practices[0]["odsCode"] == "" or len(list_of_practices[0]["metrics"]) < 6:
        raise InvalidMetrics("Invalid national metrics: a practice " + list_of_practices[
            0] + " does not contain 6 months worth of metrics OR it does not contain an ODS Code")

    return True


def _validate_national_metrics(national_metrics):
    national_metrics_json = json.loads(national_metrics)
    transfer_count = national_metrics_json["metrics"][0]["transferCount"]
    month = national_metrics_json["metrics"][0]["month"]
    # take the month when data was generated and subtract one to obtain the previous month
    date_when_generated = national_metrics_json["generatedOn"][:10]
    datetime_when_generated = datetime.strptime(date_when_generated, '%Y-%m-%d')
    last_month = datetime_when_generated.replace(day=1) - timedelta(days=1)

    if transfer_count < 150_000 or month != last_month.month:
        raise InvalidMetrics(
            "Invalid national metrics: the transfer count is smaller than 150 000 or the month is "
            "incorrect.")
    return True


def _fetch_objects_from_s3():
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)
    s3 = boto3.client("s3")
    try:
        print("Fetching ssm parameters:")
        print("Fetching s3_file_name_national_metrics ssm parameters:")
        s3_file_name_national_metrics = secret_manager.get_secret(os.environ["S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME"])
        print("Fetching s3_file_name_practice_metrics ssm parameters:")
        s3_file_name_practice_metrics = secret_manager.get_secret(os.environ["S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME"])
    except Exception as e:
        print("Unable to fetch SSM Parameter", e)
        raise UnableToFetchSSMParameter

    print("Fetching bucket env var")
    bucket = os.environ["S3_METRICS_BUCKET_NAME"]
    print("Fetching env var:")
    version = os.environ["S3_METRICS_VERSION"]
    key_national = version + "/" + s3_file_name_national_metrics
    key_practice = version + "/" + s3_file_name_practice_metrics

    try:
        print("Fetching files from s3")
        print("Fetching practice metrics file from s3")
        practice_response = s3.get_object(
            Bucket=bucket,
            Key=key_practice)
        practice_metrics_body = practice_response["Body"].read().decode()

        print("Fetching national metrics file from s3")
        national_response = s3.get_object(
            Bucket=bucket,
            Key=key_national)
        national_metrics_body = national_response["Body"].read().decode()
    except Exception as e:
        print("Unable to fetch objects from S3: ", e)
        raise UnableToFetchObjectFromS3()

    return [practice_metrics_body, national_metrics_body]
