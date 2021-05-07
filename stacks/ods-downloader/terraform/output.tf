resource "aws_ssm_parameter" "ods_downloader_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.ods_downloader.arn
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "ods_downloader_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/iam-role-arn"
  type  = "String"
  value = aws_iam_role.ods_downloader.arn
  tags  = local.common_tags
}
