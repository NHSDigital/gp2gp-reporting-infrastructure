import json
import logging
import os
from datetime import datetime

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
        logging.error("Invalid metrics, failed to deploy" + str(exception))
        raise exception
    logging.log("The practice and national metrics files are valid. Continue to deploy.")


def _validate_metrics(practice_metrics, national_metrics):
    return _validate_practice_metrics(practice_metrics) and _validate_national_metrics(national_metrics)


def _validate_practice_metrics(practice_metrics):
    practice_metrics_json = json.loads(practice_metrics)
    list_of_sicbls = practice_metrics_json["Body"]["sicbls"]
    list_of_practices = practice_metrics_json["Body"]["practices"]
    first_condition = False
    second_condition = False

    # Check one instance of SICBLs in practiceMetrics.json contains > 0 practice ODS codes - larger than 0?
    for sicbl in list_of_sicbls:
        print(sicbl)
        if len(sicbl['practices']) > 0 and sicbl['practices'][0] != "":
            first_condition = True

    # Check at least once practice exists with an ODS code and 6 months worth of metrics, including the latest month.
    for practice in list_of_practices:
        if practice["odsCode"] != "" and len(practice["metrics"]) >= 6:
            second_condition = True  # what does it mean an ods Code is not in?

    if not first_condition or not second_condition:
        raise InvalidMetrics
    return True


def _validate_national_metrics(national_metrics):
    national_metrics_json = json.loads(national_metrics)
    transfer_count = national_metrics_json["Body"]["metrics"][0]["transferCount"]
    month = national_metrics_json["Body"]["metrics"][0]["month"]
    date_when_generated = national_metrics_json["Body"]["generatedOn"]
    datetime_when_generated = datetime.strptime(date_when_generated, '%Y-%m-%d %H:%M:%S.%f')

    if transfer_count < 150_000 or month is not (datetime_when_generated.month - 1):
        raise InvalidMetrics
    return True


def _fetch_objects_from_s3():
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)
    s3 = boto3.client("s3")
    try:
        print("Fetching ssm parameters:")
        s3_file_name_national_metrics = secret_manager.get_secret(os.environ["S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME"])
        s3_file_name_practice_metrics = secret_manager.get_secret(os.environ["S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME"])
        bucket = secret_manager.get_secret(os.environ["S3_METRICS_BUCKET_PARAM_NAME"])
        print("Fetching env var:")
        version = os.environ["S3_METRICS_VERSION"]
        key_national = version + "/" + s3_file_name_national_metrics
        key_practice = version + "/" + s3_file_name_practice_metrics
    except Exception as e:
        print("Unable to fetch SSM Parameter", e)
        raise UnableToFetchSSMParameter
    try:
        print("Fetching files from s3")
        practice_response = s3.get_object(
            Bucket=bucket,
            Key=key_practice)
        practice_metrics_body = practice_response['Body'].read().decode()

        national_response = s3.get_object(
            Bucket=bucket,
            Key=key_national)
        national_metrics_body = national_response['Body'].read().decode()
    except Exception as e:
        print("Unable to fetch objects from S3: ", e)
        raise UnableToFetchObjectFromS3()

    return [practice_metrics_body, national_metrics_body]
