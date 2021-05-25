resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/${var.environment}/data-pipeline/ods-downloader"

  tags = {
    Name      = "ODS data downloader"
    CreatedBy = var.repo_name
    Team      = var.team
  }
}

resource "aws_ecr_repository" "platform_metrics_calculator" {
  name = "registrations/${var.environment}/data-pipeline/platform-metrics-calculator"

  tags = {
    Name      = "Platform metrics calculator"
    CreatedBy = var.repo_name
    Team      = var.team
  }
}