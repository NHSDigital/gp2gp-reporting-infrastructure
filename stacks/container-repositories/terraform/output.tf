resource "aws_ssm_parameter" "ods_downloader" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/ods-downloader"
  type  = "String"
  value = aws_ecr_repository.ods_downloader.repository_url
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "metrics_calculator" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/metrics-calculator"
  type  = "String"
  value = aws_ecr_repository.metrics_calculator.repository_url
  tags  = local.common_tags
}


