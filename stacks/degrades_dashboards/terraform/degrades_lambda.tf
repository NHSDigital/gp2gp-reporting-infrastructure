resource "aws_lambda_function" "degrades_lambda" {
  filename         = var.degrades_lambda_zip_file
  function_name    = "${var.environment}_${var.degrades_lambda_name}"
  role             = aws_iam_role.degrades_lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.degrades_lambda.output_base64sha256
  timeout          = 15
}


data "archive_file" "degrades_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/degrades_dashboards"
  output_path = var.degrades_lambda_zip_file
}