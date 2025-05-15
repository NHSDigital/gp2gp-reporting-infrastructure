resource "aws_ecr_repository" "ods_downloader" {
  name = "registrations/${var.environment}/data-pipeline/ods-downloader"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-ods-data-downloader"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}

resource "aws_ecr_repository" "metrics_calculator" {
  name = "registrations/${var.environment}/data-pipeline/metrics-calculator"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-metrics-calculator"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}

resource "aws_ecr_repository" "transfer_classifier" {
  name = "registrations/${var.environment}/data-pipeline/transfer-classifier"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-transfer-classifier"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}

resource "aws_ecr_repository" "spine_exporter" {
  name = "registrations/${var.environment}/data-pipeline/spine-exporter"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-spine-exporter"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}

resource "aws_ecr_repository" "reports_generator" {
  name = "registrations/${var.environment}/data-pipeline/reports-generator"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-reports-generator"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}

resource "aws_ecr_repository" "gp2gp_dashboard" {
  name = "registrations/${var.environment}/data-pipeline/gp2gp-dashboard"

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-gp2gp-dashboard"
      ApplicationRole = "AwsEcrRepository"
    }
  )
}
