resource "aws_iam_role" "platform_metrics_calculator" {
  name                = "${var.environment}-registrations-platform-metrics-calculator"
  description         = "Role for platform metrics calculator ECS task"
  assume_role_policy  = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [aws_iam_policy.platform_metrics_calculator_input_bucket_read_access.arn, aws_iam_policy.ods_output_bucket_write_access.arn]
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

resource "aws_iam_policy" "platform_metrics_calculator_input_bucket_read_access" {
  name   = "${aws_s3_bucket.platform_metrics_calculator.bucket}-read"
  policy = data.aws_iam_policy_document.platform_metrics_calculator_input_bucket_read_access.json
}

data "aws_iam_policy_document" "platform_metrics_calculator_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.platform_metrics_calculator.bucket}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.platform_metrics_calculator.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "ods_output_bucket_write_access" {
  name   = "${aws_s3_bucket.platform_metrics_calculator.bucket}-write"
  policy = data.aws_iam_policy_document.ods_output_bucket_write_access.json
}

data "aws_iam_policy_document" "ods_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.platform_metrics_calculator.bucket}/*"
    ]
  }
}