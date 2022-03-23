data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_lambda_function" "gocd_trigger" {
  filename      = var.gocd_trigger_lambda_zip
  function_name = "${var.environment}-dashboard-pipeline-gocd-trigger"
  role          = aws_iam_role.gocd_trigger.arn
  handler       = "main.lambda_handler"
  tags          = local.common_tags

  source_code_hash = filebase64sha256(var.gocd_trigger_lambda_zip)

  runtime = "python3.9"

  environment {
    variables = {
      GOCD_API_TOKEN_PARAM_NAME = var.gocd_trigger_api_token_ssm_param_name
      GOCD_API_URL_PARAM_NAME   = var.gocd_trigger_api_url_ssm_param_name
    }
  }
}

resource "aws_iam_role" "gocd_trigger" {
  name               = "${var.environment}-dashboard-pipeline-gocd-trigger"
  description        = "IAM Role for dashboard-pipeline-gocd-trigger lambda that allows access to SSM Parameter store"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.webhook_ssm_access.arn,
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