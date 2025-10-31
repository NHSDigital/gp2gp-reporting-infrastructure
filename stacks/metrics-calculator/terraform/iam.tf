data "aws_ssm_parameter" "transfers_data_bucket_name" {
  name = var.transfers_data_bucket_param_name
}

data "aws_ssm_parameter" "transfers_data_bucket_read_access_arn" {
  name = var.transfer_data_bucket_read_access_param_name
}

data "aws_ssm_parameter" "ods_metadata_bucket_read_access_arn" {
  name = var.ods_metadata_bucket_read_access_arn
}


resource "aws_iam_role" "metrics_calculator" {
  name               = "${var.environment}-registrations-metrics-calculator"
  description        = "Role for metrics calculator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "transfers_data_bucket_read_access_arn" {
  role       = aws_iam_role.metrics_calculator.name
  policy_arn = data.aws_ssm_parameter.transfers_data_bucket_read_access_arn.value
}

resource "aws_iam_role_policy_attachment" "ods_metadata_bucket_read_access_arn" {
  role       = aws_iam_role.metrics_calculator.name
  policy_arn = data.aws_ssm_parameter.ods_metadata_bucket_read_access_arn.value
}

resource "aws_iam_role_policy_attachment" "metrics_calculator_output_bucket_write_access" {
  role       = aws_iam_role.metrics_calculator.name
  policy_arn = aws_iam_policy.metrics_calculator_output_bucket_write_access.arn
}

resource "aws_iam_role_policy_attachment" "ssm_put_access" {
  role       = aws_iam_role.metrics_calculator.name
  policy_arn = aws_iam_policy.ssm_put_access.arn
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

resource "aws_iam_policy" "ssm_put_access" {
  name   = "${var.environment}-metrics-calculator-ssm-put-access"
  policy = data.aws_iam_policy_document.ssm_put_access.json
}

data "aws_iam_policy_document" "ssm_put_access" {
  statement {
    sid = "PutSSMParameter"

    actions = [
      "ssm:PutParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${local.account_id}:parameter${var.national_metrics_s3_path_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${local.account_id}:parameter${var.practice_metrics_s3_path_param_name}",
    ]
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
