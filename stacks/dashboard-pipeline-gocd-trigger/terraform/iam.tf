data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "gocd_trigger" {
  name               = "${var.environment}-dashboard-pipeline-gocd-trigger"
  description        = "IAM Role for dashboard-pipeline-gocd-trigger lambda that allows access to SSM Parameter store"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.webhook_ssm_access.arn,
    aws_iam_policy.cloudwatch_log_access.arn,
    aws_iam_policy.lambda_vpc_execution_access.arn
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

resource "aws_iam_policy" "lambda_vpc_execution_access" {
  name   = "${var.environment}-dashboard-pipeline-gocd-trigger-lambda-vpc-access"
  policy = data.aws_iam_policy_document.lambda_vpc_execution_access.json
}

data "aws_iam_policy_document" "lambda_vpc_execution_access" {
  statement {
    sid = "AWSLambdaVPCAccessExecutionRole"
    actions = [
      "ec2:CreateNetworkInterface"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${local.account_id}:subnet/${data.aws_ssm_parameter.gocd_subnet_id.value}"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_log_access" {
  name   = "${var.environment}-dashboard-pipeline-gocd-trigger-cloudwatch-log-access"
  policy = data.aws_iam_policy_document.cloudwatch_log_access.json
}

data "aws_iam_policy_document" "cloudwatch_log_access" {
  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.gocd_trigger.arn}:*"
    ]
  }
}


resource "aws_iam_policy" "webhook_ssm_access" {
  name   = "${var.environment}-dashboard-pipeline-gocd-trigger-get-ssm-access"
  policy = data.aws_iam_policy_document.webhook_ssm_access.json
}


data "aws_iam_policy_document" "webhook_ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter${var.gocd_trigger_api_url_ssm_param_name}",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter${var.gocd_trigger_api_token_ssm_param_name}"
    ]
  }
}
