resource "aws_ssm_parameter" "cloudwatch_log_group_name" {
  name = "/registrations/${var.environment}/data-pipeline/cloudwatch-log-group-name"
  type = "String"
  value = aws_cloudwatch_log_group.data_pipeline.name
  tags = local.common_tags
}

resource "aws_ssm_parameter" "execution_role_arn" {
  name = "/registrations/${var.environment}/data-pipeline/ecs-execution-role-arn"
  type = "String"
  value = aws_iam_role.ecs_execution.arn
  tags = local.common_tags
}
