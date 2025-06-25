resource "aws_lambda_function" "degrades_daily_summary_lambda" {
  function_name = "${var.environment}_${var.degrades_daily_summary_lambda_name}"
  role          = ""
}

# resource "aws_lambda_permission" "degrades_daily_summary_lambda" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.degrades_daily_summary_lambda.function_name
#   principal     = ""
# }