data "aws_ssm_parameter" "transfers_input_bucket_name" {
  name = var.transfers_input_bucket_param_name
}

data "aws_ssm_parameter" "transfers_input_bucket_read_access_arn" {
  name = var.transfer_input_bucket_read_access_param_name
}

resource "aws_iam_role" "reports_generator" {
  name               = "${var.environment}-registrations-reports-generator"
  description        = "Role for reports generator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    data.aws_ssm_parameter.transfers_input_bucket_read_access_arn.value,
    aws_iam_policy.reports_generator_output_buckets_write_access.arn
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

resource "aws_iam_policy" "reports_generator_output_buckets_write_access" {
  name   = "reports-generator-output-buckets-${var.environment}-write"
  policy = data.aws_iam_policy_document.reports_generator_output_buckets_write_access.json
}

data "aws_iam_policy_document" "reports_generator_output_buckets_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.reports_generator.bucket}/*",
      "arn:aws:s3:::${var.notebook_data_bucket_name}/*"
    ]
  }
}