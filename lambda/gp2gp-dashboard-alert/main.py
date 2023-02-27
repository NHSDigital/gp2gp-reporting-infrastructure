import urllib3
import boto3
import json
import os

from botocore.exceptions import ClientError

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    print(event)
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    gp2gp_dashboard_step_function_url = os.environ["GP2GP_DASHBOARD_STEP_FUNCTION_URL"]
    gp2gp_dashboard_national_statistics_url = os.environ["GP2GP_DASHBOARD_NATIONAL_STATISTICS_URL"]

    text = (
        f"<h2>🟢  The dashboard has successfully been deployed  🎉</h2>"
        f"<a href='{gp2gp_dashboard_national_statistics_url}'>Click here to see the GP2GP Dashboard - National Statistics.</a>"
    )

    if event is dict:
        if "metricsFailed" in event:
            text = (
                f"<h2>There was an error running the gp2gp dashboard step function</h2>"
                f"<p>Reason: Unable to run metrics calculator. See relevant cloudwatch logs for more details.</p>"
                f"<a href='{gp2gp_dashboard_step_function_url}'>Click here to see the step function overview.</a>"
            )
        elif "validationError" in event:
            text = (
                f"<h2>There was an error running the gp2gp dashboard step function</h2>"
                f"<p>Reason: Validation failed. See relevant cloudwatch logs for more details.</p>"
                f"<a href='{gp2gp_dashboard_step_function_url}'>Click here to see the step function overview.</a>"
            )
        elif "dashboardError" in event:
            text = (
                f"<h2>There was an error running the gp2gp dashboard step function</h2>"
                f"<p>Reason: Failed to build/deploy the dashboard. See relevant cloudwatch logs for more details.</p>"            
                f"<a href='{gp2gp_dashboard_step_function_url}'>Click here to see the step function overview.</a>"
            )

    msg = {
        "text": text,
        "textFormat": "markdown"
    }
    pipeline_error_encoded_msg = json.dumps(msg).encode('utf-8')

    pipeline_error_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])

    try:
        pipeline_error_alert_resp = http.request('POST', url=pipeline_error_alert_webhook_url, body=pipeline_error_encoded_msg)

        print({
            "message": msg["text"],
            "status_code": pipeline_error_alert_resp.status,
            "response": pipeline_error_alert_resp.data,
            "alert_type": "pipeline_error_technical_failure_rates",
        })

    except ClientError as e:
        print(e.response['Error']['Message'])
    except Exception as e:
        print("An error has occurred: ", e)
    else:
        print("Successfully sent alert")
