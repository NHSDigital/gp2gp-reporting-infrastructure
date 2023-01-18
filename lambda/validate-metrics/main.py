import urllib3

http = urllib3.PoolManager()


class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    # ssm = boto3.client("ssm")
    # secret_manager = SsmSecretManager(ssm)
    #
    # cloudwatch_dashboard_url = os.environ["CLOUDWATCH_DASHBOARD_URL"]
    # pipeline_error_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])
    print("validate metrics lambda successful")
    pass
