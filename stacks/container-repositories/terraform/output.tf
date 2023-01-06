resource "aws_ssm_parameter" "ods_downloader" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/ods-downloader"
  type  = "String"
  value = aws_ecr_repository.ods_downloader.repository_url
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-ods-downloader"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "metrics_calculator" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/metrics-calculator"
  type  = "String"
  value = aws_ecr_repository.metrics_calculator.repository_url
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-metrics-calculator"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "transfer_classifier" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/transfer-classifier"
  type  = "String"
  value = aws_ecr_repository.transfer_classifier.repository_url
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "spine_exporter" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/spine-exporter"
  type  = "String"
  value = aws_ecr_repository.spine_exporter.repository_url
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-spine-exporter"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "reports_generator" {
  name  = "/registrations/${var.environment}/data-pipeline/ecr/url/reports-generator"
  type  = "String"
  value = aws_ecr_repository.reports_generator.repository_url
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-reports-generator"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}
