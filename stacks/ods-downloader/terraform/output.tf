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

resource "aws_ssm_parameter" "ods_downloader_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.ods_output.bucket
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "ods_downloader_input_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/asid-lookup-bucket-name"
  type  = "String"
  value = aws_s3_bucket.ods_input.bucket
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "ods_downloader_output_bucket_read_access_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/output-bucket-read-access-arn"
  type  = "String"
  value = aws_iam_policy.ods_output_bucket_read_access.arn
  tags  = local.common_tags
}