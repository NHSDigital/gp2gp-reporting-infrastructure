# Log-alerts-pipeline

## Purpose of the Lambda

The `log-alerts-pipeline` lambda is designed to send alerts to send a message to a Slack channel warning whenever a lambda fails. It is triggered by CloudWatch logs and has a filter so that any relevant failures will trigger the lambda which sends a notification to the Slack channel along with a link to the CloudWatch custom dashboards.

## Steps involved

After the Lambda is triggered it grabs the slack_channel_id and slack_bot_token from SSM and runs the send_slack_alert function. This in turn creates a slack message including a warning message and a link to the custom CloudWatch dashboards in order to find the
failure.

## Manual Running process/Testing the Lambda

To manually test this Lambda you will not need to provide it with a payload and should be able to navigate to the `log-alerts-pipeline-error-lambda` and manually trigger it through the console.
