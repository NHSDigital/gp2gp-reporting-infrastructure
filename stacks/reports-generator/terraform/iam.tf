data "aws_ssm_parameter" "transfers_input_bucket_read_access_arn" {
  name = var.transfer_input_bucket_read_access_param_name
}

resource "aws_iam_role" "reports_generator" {
  name               = "${var.environment}-registrations-reports-generator"
  description        = "Role for reports generator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "transfers_input_bucket_read_access" {
  role       = aws_iam_role.reports_generator.name
  policy_arn = data.aws_ssm_parameter.transfers_input_bucket_read_access_arn.value
}
resource "aws_iam_role_policy_attachment" "reports_generator_output_bucker_write_access" {
  role       = aws_iam_role.reports_generator.name
  policy_arn = aws_iam_policy.reports_generator_output_buckets_write_access.arn
}

resource "aws_iam_role_policy_attachment" "notebook_data_bucket_read_access" {
  role       = aws_iam_role.reports_generator.name
  policy_arn = aws_iam_policy.notebook_data_bucket_read_access.arn
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

resource "aws_iam_policy" "notebook_data_bucket_read_access" {
  name   = "${var.notebook_data_bucket_name}-read"
  policy = data.aws_iam_policy_document.notebook_data_output_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "notebook_data_output_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.notebook_data_bucket_name}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.notebook_data_bucket_name}/*"
    ]
  }
}
