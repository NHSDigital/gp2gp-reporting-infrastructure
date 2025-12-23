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

data "aws_ssm_parameter" "prod_aws_account_id" {
  count = var.environment == "dev" ? 1 : 0
  name  = "/registrations/dev/user-input/prod-aws-account-id"
}

data "aws_iam_policy_document" "ecr_prod_account_permissions" {
  count = var.environment == "dev" ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.prod_aws_account_id[0].value]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:ListImages",
    ]
  }
}

resource "aws_ecr_repository_policy" "gp2gp_dashboard" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.gp2gp_dashboard.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}

resource "aws_ecr_repository_policy" "reports_generator" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.reports_generator.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}

resource "aws_ecr_repository_policy" "spine_exporter" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.spine_exporter.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}

resource "aws_ecr_repository_policy" "transfer_classifier" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.transfer_classifier.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}

resource "aws_ecr_repository_policy" "metrics_calculator" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.metrics_calculator.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}

resource "aws_ecr_repository_policy" "ods_downloader" {
  count      = var.environment == "dev" ? 1 : 0
  repository = aws_ecr_repository.ods_downloader.name
  policy     = data.aws_iam_policy_document.ecr_prod_account_permissions[0].json
}
