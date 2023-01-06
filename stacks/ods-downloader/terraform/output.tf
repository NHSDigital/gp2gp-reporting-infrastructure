resource "aws_ssm_parameter" "ods_downloader_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.ods_downloader.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader-task-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "ods_downloader_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/iam-role-arn"
  type  = "String"
  value = aws_iam_role.ods_downloader.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader-iam-role-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "ods_downloader_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.ods_output.bucket
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader-output-bucket-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "ods_downloader_input_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/asid-lookup-bucket-name"
  type  = "String"
  value = aws_s3_bucket.ods_input.bucket
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader-input-bucket-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "ods_downloader_output_bucket_read_access_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ods-downloader/output-bucket-read-access-arn"
  type  = "String"
  value = aws_iam_policy.ods_output_bucket_read_access.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader-output-bucket-read-access-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}