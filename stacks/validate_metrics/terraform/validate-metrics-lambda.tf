resource "aws_lambda_function" "validate_metrics_lambda" {
  filename         = var.validate_metrics_lambda_zip
  function_name    = "${var.environment}-${var.validate_metrics_lambda_name}"
  role             = aws_iam_role.validate_metrics_lambda_role.arn
  handler          = "main.lambda_handler"
  source_code_hash = filebase64sha256("${var.validate_metrics_lambda_zip}")
  runtime          = "python3.14"
  timeout          = 15
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-${var.validate_metrics_lambda_name}"
      ApplicationRole = "AwsLambdaFunction"
    }
  )

  environment {
    variables = {
      S3_NATIONAL_METRICS_FILEPATH_PARAM_NAME = var.s3_national_metrics_filepath_param_name
      S3_PRACTICE_METRICS_FILEPATH_PARAM_NAME = var.s3_practice_metrics_filepath_param_name
      S3_METRICS_BUCKET_NAME                  = data.aws_ssm_parameter.metrics_input_bucket_name.value
      S3_METRICS_VERSION                      = var.s3_metrics_version
    }
  }
}