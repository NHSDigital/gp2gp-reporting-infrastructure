# Degrades API Lambda
data "aws_iam_policy_document" "degrades_api_lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "degrades_api_lambda_role" {
  name               = "${var.environment}_degrades_api_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.degrades_api_lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "degrades_api_lambda_s3_access" {
  role       = aws_iam_role.degrades_api_lambda_role.name
  policy_arn = aws_iam_policy.registrations_mi_events_access.arn
}

resource "aws_iam_policy" "registrations_mi_events_access" {
  name   = "regristrations_mi_events_read_policy"
  policy = data.aws_iam_policy_document.registrations_mi_events_access.json
}

data "aws_iam_policy_document" "registrations_mi_events_access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetObjectRetention",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectAttributes",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
    ]
    resources = [
    "arn:aws:s3:::${var.registrations_mi_event_bucket}/*", "arn:aws:s3:::${var.registrations_mi_event_bucket}"]
  }
}