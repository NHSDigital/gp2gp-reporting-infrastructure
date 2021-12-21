data "aws_ssm_parameter" "transfers_input_bucket_name" {
  name = var.transfers_input_bucket_param_name
}

resource "aws_iam_role" "reports_generator" {
  name               = "${var.environment}-registrations-reports-generator"
  description        = "Role for reports generator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.reports_generator_transfers_input_bucket_read_access.arn,
    aws_iam_policy.reports_generator_output_bucket_write_access.arn
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

resource "aws_iam_policy" "reports_generator_transfers_input_bucket_read_access" {
  name   = "${data.aws_ssm_parameter.transfers_input_bucket_name.value}-read"
  policy = data.aws_iam_policy_document.reports_generator_transfers_input_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "reports_generator_transfers_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.transfers_input_bucket_name.value}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.transfers_input_bucket_name.value}/*"
    ]
  }
}

resource "aws_iam_policy" "reports_generator_output_bucket_write_access" {
  name   = "${aws_s3_bucket.reports_generator.bucket}-write"
  policy = data.aws_iam_policy_document.reports_generator_output_bucket_write_access.json
}

data "aws_iam_policy_document" "reports_generator_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.reports_generator.bucket}/*"
    ]
  }
}