resource "aws_lambda_function" "gocd_trigger" {
  filename      = var.gocd_trigger_lambda_zip
  function_name = "${var.environment}-dashboard-pipeline-gocd-trigger"
  role          = aws_iam_role.gocd_trigger.arn
  handler       = "main.lambda_handler"
  tags          = local.common_tags

  source_code_hash = filebase64sha256(var.gocd_trigger_lambda_zip)

  runtime = "python3.9"
}

resource "aws_iam_role" "gocd_trigger" {
  name               = "${var.environment}-dashboard-pipeline-gocd-trigger"
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
