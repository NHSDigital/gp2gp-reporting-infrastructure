data "aws_ssm_parameter" "metrics_input_bucket_name" {
  name = var.metrics_input_bucket_param_name
}

resource "aws_iam_role" "gp2gp_dashboard" {
  name               = "${var.environment}-registrations-gp2gp-dashboard"
  description        = "Role for gp2gp dashboard ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.gp2gp_dashboard_output_bucket_write_access.arn,
    aws_iam_policy.metrics_input_bucket_read_access.arn,
    aws_iam_policy.metrics_ssm_parameter_read_access.arn
  ]
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = [
    "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "gp2gp_dashboard_output_bucket_write_access" {
  name   = "gp2gp-dashboard-output-buckets-${var.environment}-write"
  policy = data.aws_iam_policy_document.gp2gp_dashboard_output_bucket_write_access.json
}

data "aws_iam_policy_document" "gp2gp_dashboard_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:PutBucketWebsite"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.dashboard_website.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.dashboard_website.bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "metrics_input_bucket_read_access" {
  name   = "${var.environment}-metrics-input-bucket-read-access"
  policy = data.aws_iam_policy_document.metrics_input_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "metrics_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.metrics_input_bucket_name.value}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.metrics_input_bucket_name.value}/*"
    ]
  }
}

resource "aws_iam_policy" "metrics_ssm_parameter_read_access" {
  name   = "${var.environment}-metrics-ssm-parameter-read-access"
  policy = data.aws_iam_policy_document.metrics_ssm_parameter_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "metrics_ssm_parameter_read_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}:${local.account_id}:parameter/registrations/${var.environment}/data-pipeline/metrics-calculator/practice-metrics-s3-path",
      "arn:aws:ssm:${data.aws_region.current.id}:${local.account_id}:parameter/registrations/${var.environment}/data-pipeline/metrics-calculator/national-metrics-s3-path"
    ]
  }
}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
