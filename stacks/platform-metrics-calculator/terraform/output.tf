resource "aws_ssm_parameter" "platform_metrics_calculator_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/platform-metrics-calculator/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.platform_metrics_calculator.arn
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "platform_metrics_calculator_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/platform-metrics-calculator/iam-role-arn"
  type  = "String"
  value = aws_iam_role.platform_metrics_calculator.arn
  tags  = local.common_tags
}
