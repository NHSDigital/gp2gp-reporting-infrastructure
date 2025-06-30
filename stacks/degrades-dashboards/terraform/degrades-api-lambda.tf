resource "aws_lambda_function" "degrades_api_lambda" {
  filename         = var.degrades_dashboards_api_lambda_zip
  function_name    = "${var.environment}_${var.degrades_api_lambda_name}"
  role             = aws_iam_role.degrades_api_lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${var.degrades_dashboards_api_lambda_zip}")
  timeout          = 45
  memory_size      = 512
  layers           = [aws_lambda_layer_version.degrades_lambda_layer.arn]
  environment {
    variables = {
      REGISTRATIONS_MI_EVENT_BUCKET = "${var.registrations_mi_event_bucket}"
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.degrades_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.degrades_api.execution_arn}/*/*"
}