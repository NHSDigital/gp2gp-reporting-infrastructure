resource "aws_ssm_parameter" "gp2gp_dashboard_task_definition_arn" {
  name = "/registrations/${var.environment}/data-pipeline/gp2gp-dashboard/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.gp2gp_dashboard.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-gp2gp-dashboard-task-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "gp2gp_dashboard_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/gp2gp-dashboard/iam-role-arn"
  type  = "String"
  value = aws_iam_role.gp2gp_dashboard.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-p2gp-dashboard-iam-role-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}