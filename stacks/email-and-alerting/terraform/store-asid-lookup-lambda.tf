data "aws_sfn_state_machine" "ods_downloader" {
  name = "ods-downloader-pipeline"
}

resource "aws_lambda_function" "store_asid_lookup" {
  function_name    = "${var.environment}_${var.store_asid_lookup_lambda_name}"
  filename         = var.store_asid_lookup_lambda_zip
  role             = aws_iam_role.store_asid_lookup_lambda.arn
  runtime          = "python3.9"
  handler          = "main.lambda_handler"
  timeout          = 60
  memory_size      = 1769
  source_code_hash = filebase64sha256("${var.store_asid_lookup_lambda_zip}")

  environment {
    variables = {
      ENVIRONMENT = var.environment,
      EMAIL_USER  = data.aws_ssm_parameter.asid_lookup_address_prefix.value,
    }
  }
}

resource "aws_cloudwatch_log_group" "store_asid_lookup" {
  name              = "/aws/lambda/${aws_lambda_function.store_asid_lookup.function_name}"
  retention_in_days = 0
}

# https://github.com/hashicorp/terraform-provider-aws/issues/7917
resource "aws_lambda_permission" "store_asid_lookup_ses_trigger" {
  statement_id  = "AllowExecutionFromSES"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.store_asid_lookup.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "${aws_ses_receipt_rule_set.gp2gp_inbox.arn}:receipt-rule/${local.ses_receipt_rule_asid_lookup_name}"
}

