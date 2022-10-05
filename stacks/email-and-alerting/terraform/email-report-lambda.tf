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
      LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME = var.log_alerts_technical_failures_above_threshold_rate_param_name,
      EMAIL_REPORT_SENDER_EMAIL_PARAM_NAME = var.email_report_sender_email_param_name,
      EMAIL_REPORT_RECIPIENT_EMAIL_PARAM_NAME = var.email_report_recipient_email_param_name
      EMAIL_REPORT_RECIPIENT_INTERNAL_EMAIL_PARAM_NAME = var.email_report_recipient_internal_email_param_name
      EMAIL_REPORT_SENDER_EMAIL_KEY_PARAM_NAME = var.email_report_sender_email_key_param_name
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

resource "aws_lambda_permission" "allow_trigger_from_s3_object_created" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_report_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${data.aws_ssm_parameter.reports_generator_bucket_name.value}"
  source_account= data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_notification" "reports_generator_s3_object_created" {
  count  = var.environment == "dev" ? 0 : 1
  bucket = data.aws_ssm_parameter.reports_generator_bucket_name.value

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_report_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_trigger_from_s3_object_created,
  ]
}



