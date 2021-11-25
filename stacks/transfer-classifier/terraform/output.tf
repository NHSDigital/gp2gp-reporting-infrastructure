resource "aws_ssm_parameter" "transfer_classifier_task_definition_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/task-definition-arn"
  type  = "String"
  value = aws_ecs_task_definition.transfer_classifier.arn
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "transfer_classifier_iam_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/iam-role-arn"
  type  = "String"
  value = aws_iam_role.transfer_classifier.arn
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "transfer_classifier_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.transfer_classifier.bucket
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "transfer_classifier_notebook_data_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/transfer-classifier/notebook-data"
  type  = "String"
  value = var.transfer_classifier_notebook_data_name
  tags  = local.common_tags
}