resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/${var.environment}/data-pipeline/ods-downloader"

  tags = {
    Name      = "ODS data downloader"
    CreatedBy = var.repo_name
    Team      = var.team
  }
}
