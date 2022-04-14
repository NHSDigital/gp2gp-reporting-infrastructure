resource "aws_iam_role" "spine_exporter" {
  name               = "${var.environment}-registrations-spine-exporter"
  description        = "Role for spine exporter ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.spine_exporter_output_bucket_write_access.arn,
    aws_iam_policy.ssm_access.arn
  ]
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.environment}-spine-exporter-get-ssm-access"
  policy = data.aws_iam_policy_document.ssm_access.json
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${local.account_id}:parameter/registrations/${var.environment}/user-input/splunk-*"
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "spine_exporter_output_bucket_write_access" {
  name   = "${aws_s3_bucket.spine_exporter.bucket}-write"
  policy = data.aws_iam_policy_document.spine_exporter_output_bucket_write_access.json
}

data "aws_iam_policy_document" "spine_exporter_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.spine_exporter.bucket}/*"
    ]
  }
}