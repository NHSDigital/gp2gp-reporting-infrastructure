resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/${var.environment}/data-pipeline/ods-downloader"

  tags = merge(
    local.common_tags,
    {
      Name = "ODS data downloader"
    }
  )
}

resource "aws_ecr_repository" "metrics_calculator" {
  name = "registrations/${var.environment}/data-pipeline/metrics-calculator"

  tags = merge(
    local.common_tags,
    {
      Name = "Metrics calculator"
    }
  )
}

resource "aws_ecr_repository" "transfer_classifier" {
  name = "registrations/${var.environment}/data-pipeline/transfer-classifier"

  tags = merge(
    local.common_tags,
    {
      Name = "Transfer classifier"
    }
  )
}

resource "aws_ecr_repository" "spine_exporter" {
  name = "registrations/${var.environment}/data-pipeline/spine-exporter"

  tags = merge(
    local.common_tags,
    {
      Name = "Spine exporter"
    }
  )
}