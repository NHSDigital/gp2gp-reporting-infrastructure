resource "aws_lambda_function" "degrades_daily_summary_lambda" {
  function_name    = "${var.environment}_${var.degrades_daily_summary_lambda_name}"
  filename         = var.degrades_daily_summary_lambda_zip
  role             = aws_iam_role.degrades_daily_summary_lambda.arn
  runtime          = "python3.12"
  handler          = "main.lambda_handler"
  timeout          = 120
  source_code_hash = filebase64sha256("${var.degrades_daily_summary_lambda_zip}")
}

# resource "aws_lambda_permission" "degrades_daily_summary_lambda" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.degrades_daily_summary_lambda.function_name
#   principal     = ""
# }