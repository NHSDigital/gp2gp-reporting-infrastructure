resource "aws_ssm_parameter" "ods_downloader" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/ods-downloader"
  type  = "String"
  value = aws_ecr_repository.ods_downloader.name
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "platform_metrics_calculator" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/platform-metrics-calculator"
  type  = "String"
  value = aws_ecr_repository.platform_metrics_calculator.repository_url
  tags  = local.common_tags
}


