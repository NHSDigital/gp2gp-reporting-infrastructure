data "aws_ssm_parameter" "spine_messages_input_bucket_name" {
  name = var.spine_messages_input_bucket_param_name
}

data "aws_ssm_parameter" "ods_metadata_input_bucket_name" {
  name = var.ods_metadata_input_bucket_param_name
}

resource "aws_iam_role" "metrics_calculator" {
  name               = "${var.environment}-registrations-metrics-calculator"
  description        = "Role for metrics calculator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.metrics_calculator_transfers_input_bucket_read_access.arn,
    aws_iam_policy.metrics_calculator_ods_metadata_input_bucket_read_access.arn,
    aws_iam_policy.metrics_calculator_output_bucket_write_access.arn
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

resource "aws_iam_policy" "metrics_calculator_transfers_input_bucket_read_access" {
  name   = "${data.aws_ssm_parameter.spine_messages_input_bucket_name.value}-read"
  policy = data.aws_iam_policy_document.metrics_calculator_transfers_input_bucket_read_access.json
}

data "aws_iam_policy_document" "metrics_calculator_transfers_input_bucket_read_access" {
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

resource "aws_iam_policy" "metrics_calculator_ods_metadata_input_bucket_read_access" {
  name   = "metrics-calculator-read-${data.aws_ssm_parameter.ods_metadata_input_bucket_name.value}"
  policy = data.aws_iam_policy_document.metrics_calculator_ods_metadata_input_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "metrics_calculator_ods_metadata_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.ods_metadata_input_bucket_name.value}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.ods_metadata_input_bucket_name.value}/*"
    ]
  }
}

resource "aws_iam_policy" "metrics_calculator_output_bucket_write_access" {
  name   = "${aws_s3_bucket.metrics_calculator.bucket}-write"
  policy = data.aws_iam_policy_document.metrics_calculator_output_bucket_write_access.json
}

data "aws_iam_policy_document" "metrics_calculator_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.metrics_calculator.bucket}/*"
    ]
  }
}