resource "aws_lambda_function" "log_alert_lambda" {
  filename      = var.log_alerts_lambda_zip
  function_name = "${var.environment}-log-alert-lambda"
  role          = aws_iam_role.alarm_notifications_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.log_alerts_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_WEBHOOK_URL_PARAM_NAME = var.log_alerts_webhook_ssm_path
    }
  }
}

resource "aws_iam_policy" "cloudwatch_log_access" {
  name   = "${var.environment}-log-alerts-cloudwatch-log-access"
  policy = data.aws_iam_policy_document.cloudwatch_log_access.json
}

resource "aws_cloudwatch_log_group" "log_alerts" {
  name = "/aws/lambda/${var.environment}-log_alerts"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-log-alerts-lambda"
    }
  )
  retention_in_days = 14
}

data "aws_iam_policy_document" "cloudwatch_log_access" {
  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.log_alerts.arn}:*"
    ]
  }
}

resource "aws_iam_role" "alarm_notifications_lambda_role" {
  name               = "${var.environment}-log-alert-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "webhook_ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_webhook_ssm_path}"
    ]
  }
}

resource "aws_iam_policy" "webhook_ssm_access" {
  name   = "${var.environment}-webhook-ssm-access"
  policy = data.aws_iam_policy_document.webhook_ssm_access.json
}

resource "aws_iam_role_policy_attachment" "webhook_ssm_access_attachment" {
  role       = aws_iam_role.alarm_notifications_lambda_role.name
  policy_arn = aws_iam_policy.webhook_ssm_access.arn
}

resource "aws_cloudwatch_log_subscription_filter" "log_alert" {
  name            = "log-alerts-lambda-function-filter"
  role_arn        = aws_iam_role.alarm_notifications_lambda_role.arn
  log_group_name  = data.aws_ssm_parameter.cloud_watch_log_group.value
  filter_pattern  = '{ $.module is "reports_pipeline" && $.alert-enabled is true }'
  destination_arn = aws_iam_policy.cloudwatch_log_access.arn
  distribution    = "Random"
}
