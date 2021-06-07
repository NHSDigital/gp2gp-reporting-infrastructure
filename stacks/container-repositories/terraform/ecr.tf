resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/${var.environment}/data-pipeline/ods-downloader"

  tags = {
    Name      = "ODS data downloader"
    CreatedBy = var.repo_name
    Team      = var.team
  }
}

resource "aws_ecr_repository" "metrics_calculator" {
  name = "registrations/${var.environment}/data-pipeline/metrics-calculator"

  tags = {
    Name      = "Metrics calculator"
    CreatedBy = var.repo_name
    Team      = var.team
  }
}