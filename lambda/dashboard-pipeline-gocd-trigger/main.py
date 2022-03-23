import urllib3
import boto3
import json
import os

http = urllib3.PoolManager()

def lambda_handler(event, context):
    gocd_api_token = os.environ["A_KEY"]
    gocd_dashboard_path = os.environ["GOCD_API_URL"]

    headers = {
        "Accept": "application/vnd.go.cd.v1+json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {gocd_api_token}",
        "X-GoCD-Confirm": True,
    }
    resp = http.request('POST', url=gocd_dashboard_path, headers=headers)

    print({
        "status_code": resp.status,
        "response_data": resp.data
    })