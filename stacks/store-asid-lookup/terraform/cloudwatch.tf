resource "aws_cloudwatch_log_group" "store_asid_lookup" {
  name              = "/aws/lambda/${aws_lambda_function.store_asid_lookup.function_name}"
  retention_in_days = 60
}
