resource "aws_iam_role" "spine_exporter" {
  name               = "${var.environment}-registrations-spine-exporter"
  description        = "Role for spine exporter ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
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

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.spine_exporter.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.environment}-ssm-access"
  policy = data.aws_iam_policy_document.ssm_access.json
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/registrations/${var.environment}/user-input/splunk-*"
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
