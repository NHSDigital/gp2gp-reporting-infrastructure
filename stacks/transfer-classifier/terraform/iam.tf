data "aws_ssm_parameter" "spine_messages_bucket_name" {
  name = var.spine_messages_bucket_param_name
}

data "aws_ssm_parameter" "ods_metadata_bucket_read_access_arn" {
  name = var.ods_metadata_bucket_read_access_arn
}

resource "aws_iam_role" "transfer_classifier" {
  name               = "${var.environment}-registrations-transfer-classifier"
  description        = "Role for transfer classifier ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    aws_iam_policy.spine_messages_bucket_read_access.arn,
    data.aws_ssm_parameter.ods_metadata_bucket_read_access_arn.value,
    aws_iam_policy.transfer_classifier_output_buckets_write_access.arn,
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

resource "aws_iam_policy" "spine_messages_bucket_read_access" {
  name   = "${data.aws_ssm_parameter.spine_messages_bucket_name.value}-read"
  policy = data.aws_iam_policy_document.spine_messages_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_iam_policy_document" "spine_messages_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.spine_messages_bucket_name.value}",
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.spine_messages_bucket_name.value}/*"
    ]
  }
}

resource "aws_iam_policy" "transfer_classifier_output_buckets_write_access" {
  name   = "transfer-classifier-output-buckets-${var.environment}-write"
  policy = data.aws_iam_policy_document.transfer_classifier_output_buckets_write_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "transfer_classifier_output_buckets_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.transfer_classifier.bucket}/*",
      "arn:aws:s3:::${var.notebook_data_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "transfer_classifier_output_bucket_read_access" {
  name        = "${aws_s3_bucket.transfer_classifier.bucket}-read"
  description = "Transfer Classifier S3 bucket read access needed for metrics calculator and reports generator"
  policy      = data.aws_iam_policy_document.transfer_classifier_output_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "transfer_classifier_output_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.transfer_classifier.bucket}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.transfer_classifier.bucket}/*"
    ]
  }
}
