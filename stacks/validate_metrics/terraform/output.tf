resource "aws_ssm_parameter" "validate_metrics_lambda_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/validate-metrics/lambda-arn"
  type  = "String"
  value = aws_lambda_function.validate_metrics_lambda.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-validate-metrics-lambda-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}
