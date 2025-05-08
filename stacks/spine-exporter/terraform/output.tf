resource "aws_ssm_parameter" "spine_exporter_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/spine-exporter/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.spine_exporter.bucket
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-spine-exporter-output-bucket-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "spine_exporter_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/spine-exporter/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.spine_exporter.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-spine-exporter-task-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "spine_exporter_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/spine-exporter/iam-role-arn"
  type  = "String"
  value = aws_iam_role.spine_exporter.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-spine-exporter-iam-role-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}