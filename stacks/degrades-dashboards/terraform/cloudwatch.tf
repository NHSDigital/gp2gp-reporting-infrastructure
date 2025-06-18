resource "aws_cloudwatch_log_group" "degrades_messages_receiver" {
  name = "/aws/lamda/${aws_lambda_function.degrades_message_receiver.function_name}"
  retention_in_days = 14
}