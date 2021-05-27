resource "aws_ssm_parameter" "spine_exporter_output_bucket_name" {
  name  = "/registrations/${var.environment}/data-pipeline/spine-exporter/output-bucket-name"
  type  = "String"
  value = aws_s3_bucket.spine_exporter.bucket
  tags  = local.common_tags
}