resource "aws_lambda_function" "degrades_handler" {
  function_name    = "${var.environment}_${var.degrades_message_receiver_lambda_name}"
  filename         = var.degrades_message_receiver_lambda_zip
  role             = aws_iam_role.degrades_message_receiver_lambda.arn
  runtime          = "python3.12"
  handler          = "main.lambda_handler"
  timeout          = 45
  source_code_hash = filebase64sha256("${var.degrades_message_receiver_lambda_zip}")

  environment {
    variables = {
      DEGRADES_MESSAGE_TABLE = aws_dynamodb_table.degrades_message_table.name
      AWS_REGION              = "eu-west-2"
    }
  }
}

resource "aws_lambda_event_source_mapping" "degrades_lambda" {
  function_name    = aws_lambda_function.degrades_handler.arn
  event_source_arn = aws_sqs_queue.degrades_messages.arn
}