resource "aws_ssm_parameter" "transfer_classifier_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.transfer_classifier.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier-task-definition-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "transfer_classifier_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/iam-role-arn"
  type  = "String"
  value = aws_iam_role.transfer_classifier.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier-iam-role"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "transfer_classifier_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.transfer_classifier.bucket
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier-output-bucket-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "transfer_classifier_output_bucket_read_access_policy_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/output-bucket-read-access-arn"
  type  = "String"
  value = aws_iam_policy.transfer_classifier_output_bucket_read_access.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier-output-bucket-read-access-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}