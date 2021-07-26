data "aws_ssm_parameter" "spine_messages_input_bucket_name" {
  name = var.spine_messages_input_bucket_param_name
}

resource "aws_iam_role" "transfer_classifier" {
  name               = "${var.environment}-registrations-transfer-classifier"
  description        = "Role for transfer classifier ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.transfer_classifier_transfers_input_bucket_read_access.arn,
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

resource "aws_iam_policy" "transfer_classifier_transfers_input_bucket_read_access" {
  name   = "${data.aws_ssm_parameter.spine_messages_input_bucket_name.value}-read"
  policy = data.aws_iam_policy_document.transfer_classifier_transfers_input_bucket_read_access.json
}


data "aws_iam_policy_document" "transfer_classifier_transfers_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.spine_messages_input_bucket_name.value}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.spine_messages_input_bucket_name.value}/*"
    ]
  }
}