resource "aws_lambda_function" "log_alerts_technical_failures_above_threshold_lambda" {
  filename      = var.log_alerts_technical_failures_above_threshold_lambda_zip
  function_name = "${var.environment}-log-alerts-technical-failures-above-threshold-lambda"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.log_alerts_technical_failures_above_threshold_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_WEBHOOK_URL_PARAM_NAME = var.log_alerts_technical_failures_webhook_url_param_name,
      LOG_ALERTS_EXCEEDED_THRESHOLD_WEBHOOK_URL_PARAM_NAME = var.log_alerts_technical_failures_webhook_url_param_name,
      LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME = var.log_alerts_general_webhook_url_param_name,
      LOG_ALERTS_TECHNICAL_FAILURE_RATE_THRESHOLD = var.log_alerts_technical_failures_above_threshold_rate_param_name
    }
  }
}

resource "aws_iam_policy" "cloudwatch_log_access" {
  name   = "${var.environment}-log-alerts-cloudwatch-log-access"
  policy = data.aws_iam_policy_document.cloudwatch_log_access.json
}

resource "aws_cloudwatch_log_group" "log_alerts" {
  name = "/aws/lambda/${var.environment}-log-alerts-lambda"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-log-alerts-lambda"
    }
  )
  retention_in_days = 60
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

resource "aws_iam_role" "log_alerts_lambda_role" {
  name               = "${var.environment}-log-alerts-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.webhook_ssm_access.arn,
    aws_iam_policy.cloudwatch_log_access.arn,
    ]
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
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_webhook_url_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_above_threshold_rate_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_general_webhook_url_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_above_threshold_rate_param_name}"
    ]
  }
}

resource "aws_iam_policy" "webhook_ssm_access" {
  name   = "${var.environment}-webhook-ssm-access"
  policy = data.aws_iam_policy_document.webhook_ssm_access.json
}

resource "aws_lambda_permission" "log_alerts_technical_failures_above_threshold_lambda_allow_cloudwatch" {
  statement_id = "log-alerts-technical-failures-above-threshold-lambda-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_alerts_technical_failures_above_threshold_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_ssm_parameter.cloud_watch_log_group.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "log_alerts_technical_failures_above_threshold" {
  name            = "${var.environment}-log-alerts-technical-failures-above-threshold-log-filter"
  depends_on      = [aws_lambda_permission.log_alerts_technical_failures_above_threshold_lambda_allow_cloudwatch]
  log_group_name  = data.aws_ssm_parameter.cloud_watch_log_group.value
  filter_pattern  = "{ $.module = \"reports_pipeline\" && $.alert-enabled is true }"
  destination_arn = aws_lambda_function.log_alerts_technical_failures_above_threshold_lambda.arn
}

# Pipeline error log_alerts_pipeline_error
resource "aws_lambda_function" "log_alerts_pipeline_error_lambda" {
  filename      = var.log_alerts_pipeline_error_lambda_zip
  function_name = "${var.environment}-log-alerts-pipeline-error-lambda"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.log_alerts_pipeline_error_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME = var.log_alerts_general_webhook_url_param_name,
      CLOUDWATCH_DASHBOARD_URL = var.cloudwatch_dashboard_url
    }
  }
}

resource "aws_lambda_permission" "log_alerts_pipeline_error_lambda_allow_cloudwatch" {
  statement_id = "log-alerts-pipeline-error-lambda-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_alerts_pipeline_error_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_ssm_parameter.cloud_watch_log_group.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "log_alerts_pipeline_error" {
  name            = "${var.environment}-log-alerts-pipeline-error-log-filter"
  depends_on      = [aws_lambda_permission.log_alerts_pipeline_error_lambda_allow_cloudwatch]
  log_group_name  = data.aws_ssm_parameter.cloud_watch_log_group.value
  filter_pattern  = "{ $.level = \"ERROR\" }"
  destination_arn = aws_lambda_function.log_alerts_pipeline_error_lambda.arn
}
