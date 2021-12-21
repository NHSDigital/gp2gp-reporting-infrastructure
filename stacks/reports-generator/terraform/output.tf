resource "aws_ssm_parameter" "reports_generator_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/reports-generator/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.reports_generator.arn
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "reports_generator_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/reports-generator/iam-role-arn"
  type  = "String"
  value = aws_iam_role.reports_generator.arn
  tags  = local.common_tags
}
