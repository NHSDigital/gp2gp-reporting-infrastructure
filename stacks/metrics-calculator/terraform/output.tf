resource "aws_ssm_parameter" "metrics_calculator_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/metrics-calculator/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.metrics_calculator.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-metrics-calculator-task-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "metrics_calculator_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/metrics-calculator/iam-role-arn"
  type  = "String"
  value = aws_iam_role.metrics_calculator.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-metrics-calculator-iam-role-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "metrics_calculator_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/metrics-calculator/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.metrics_calculator.bucket
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-metrics-calculator-output-bucket-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}
