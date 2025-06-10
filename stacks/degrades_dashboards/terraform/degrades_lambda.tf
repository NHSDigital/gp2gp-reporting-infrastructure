terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.23.0"
    }
  }
}
resource "aws_lambda_function" "degrades_lambda" {
  filename         = var.degrades_lambda_zip_file
  function_name    = "${var.environment}_${var.degrades_lambda_name}"
  role             = aws_iam_role.degrades_lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.degrades_lambda.output_base64sha256
  timeout          = 15
}

data "aws_iam_policy_document" "degrades_lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "degrades_lambda_role" {
  name               = "${var.environment}_degrades_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.degrades_lambda_assume_role.json
}

data "archive_file" "degrades_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/degrades_dashboards"
  output_path = var.degrades_lambda_zip_file
}

resource "aws_api_gateway_rest_api" "degrades_api" {
  name        = "degrades_api"
  description = "API for Degrades work"
}

resource "aws_api_gateway_deployment" "degrades_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_stage" "degrades" {
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
  name        = "dev"
}


resource "aws_api_gateway_resource" "degrades" {
  parent_id   = aws_api_gateway_rest_api.degrades_api.root_resource_id
  path_part   = "degrades"
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_method" "degrades_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.degrades.id
  rest_api_id   = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_integration" "degrades_get" {
  http_method = aws_api_gateway_method.degrades_get.http_method
  resource_id = aws_api_gateway_resource.degrades.id
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.degrades_lambda.invoke_arn
}