variable "gp2gp_dashboard_alert_lambda_name" {
  default = "gp2gp-dashboard-alert-lambda"
}

resource "aws_lambda_function" "gp2gp_dashboard_alert_lambda" {
  filename      = var.gp2gp_dashboard_alert_lambda_zip
  function_name = "${var.environment}-${var.gp2gp_dashboard_alert_lambda_name}"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.gp2gp_dashboard_alert_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.gp2gp_dashboard_alert_lambda_name}"
      ApplicationRole = "AwsLambdaFunction"
    }
  )

  environment {
    variables = {
      LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME = var.log_alerts_general_webhook_url_param_name,
      GP2GP_DASHBOARD_STEP_FUNCTION_URL = "https://${data.aws_region.current.name}.console.aws.amazon.com/states/home#/statemachines/view/arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:dashboard-pipeline"
    }
  }
}

#resource "aws_lambda_permission" "gp2gp_dashboard_alert_lambda_allow_cloudwatch" {
#  statement_id = "gp2gp-dashboard-alert-lambda-allow-cloudwatch"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.gp2gp_dashboard_alert_lambda.function_name
#  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
#  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_ssm_parameter.cloud_watch_log_group.value}:*"
#}

resource "aws_cloudwatch_log_group" "gp2gp_dashboard_alert" {
  name = "/aws/lambda/${var.environment}-${var.gp2gp_dashboard_alert_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.gp2gp_dashboard_alert_lambda_name}"
      ApplicationRole = "AwsCloudwatchLogGroup"
    }
  )
  retention_in_days = 60
}