variable "email_report_lambda_name" {
  default = "email-report-lambda"
}

resource "aws_lambda_function" "email_report_lambda" {
  filename      = var.email_report_lambda_zip
  function_name = "${var.environment}-${var.email_report_lambda_name}"
  role          = aws_iam_role.email_report_lambda_role.arn
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

resource "aws_cloudwatch_log_group" "email_report_lambda" {
  name = "/aws/lambda/${var.environment}-${var.email_report_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.email_report_lambda_name}"
    }
  )
  retention_in_days = 60
}

resource "aws_s3_bucket_notification" "reports_generator_s3_object_created" {
  bucket = var.reports_generator_bucket_param_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_report_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_trigger_from_s3_object_created,
  ]
}

resource "aws_lambda_permission" "allow_trigger_from_s3_object_created" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_report_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.reports_generator_bucket_param_name}/*"
}



