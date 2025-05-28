resource "aws_lambda_function" "degrades_lambda" {
  filename         = var.degrades_lambda_zip_file
  function_name    = "${var.environment}_${var.degrades_lambda_name}"
  role             = ""
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