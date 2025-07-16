resource "aws_lambda_function" "store_asid_lookup" {
  function_name    = "${var.environment}_${var.store_asid_lookup_lambda_name}"
  filename         = var.store_asid_lookup_lambda_zip
  role             = aws_iam_role.store_asid_lookup_lambda.arn
  runtime          = "python3.9"
  handler          = "main.lambda_handler"
  timeout          = 900
  source_code_hash = filebase64sha256("${var.store_asid_lookup_lambda_zip}")

  environment {
    variables = {
      ENVIRONMENT = var.environment,
    }
  }
}

resource "aws_cloudwatch_log_group" "store_asid_lookup" {
  name              = "/aws/lambda/${aws_lambda_function.store_asid_lookup.function_name}"
  retention_in_days = 0
}
