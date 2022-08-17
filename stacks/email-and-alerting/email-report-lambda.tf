variable "email_report_lambda_name" {
  default = "email-report-lambda"
}

resource "aws_lambda_function" "email_report_lambda" {
  filename      = var.email_report_lambda_zip
  function_name = "${var.environment}-${var.email_report_lambda_name}"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.email_report_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME = var.log_alerts_technical_failures_above_threshold_rate_param_name
    }
  }
}

resource "aws_iam_policy" "cloudwatch_log_access" {
  name   = "${var.environment}-email-report-cloudwatch-log-access"
  policy = data.aws_iam_policy_document.cloudwatch_log_access.json
}

resource "aws_cloudwatch_log_group" "email_report" {
  name = "/aws/lambda/${var.environment}-${var.email_report_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.email_report_lambda_name}"
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
      "${aws_cloudwatch_log_group.email_report.arn}:*",
    ]
  }
}

resource "aws_iam_role" "log_alerts_lambda_role" {
  name               = "${var.environment}-email-report-lambda-role"
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
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_above_threshold_rate_param_name}",
    ]
  }
}

resource "aws_iam_policy" "webhook_ssm_access" {
  name   = "${var.environment}-webhook-ssm-access"
  policy = data.aws_iam_policy_document.webhook_ssm_access.json
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}
