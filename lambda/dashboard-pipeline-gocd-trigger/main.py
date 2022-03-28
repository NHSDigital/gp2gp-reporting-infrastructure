import urllib3
import boto3
import os
import sys

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]

def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    gocd_api_token = secret_manager.get_secret(os.environ["GOCD_API_TOKEN_PARAM_NAME"])
    gocd_dashboard_path = secret_manager.get_secret(os.environ["GOCD_API_URL_PARAM_NAME"])

    headers = {
        "Accept": "application/vnd.go.cd.v1+json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {gocd_api_token}",
        "X-GoCD-Confirm": True,
    }

    try:
        resp = http.request('POST', url=gocd_dashboard_path, headers=headers)

        return {
            "status_code": resp.status,
            "response_data": resp.data
        }
    except Exception as e:
        print("An error has occurred: ", e)
        sys.exit(1)
