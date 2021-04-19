resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/ods-downloader"

  tags = {
    Name        = "Ods data downloader"
    CreatedBy   = var.repo_name
    Team        = var.team
  }
}
