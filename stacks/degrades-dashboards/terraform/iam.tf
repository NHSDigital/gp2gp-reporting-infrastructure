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
      "s3:AbortMultipartUpload",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectAttributes",
      "s3:GetObjectRetention",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]
    resources = [
    "arn:aws:s3:::${var.registrations_mi_event_bucket}/*", "arn:aws:s3:::${var.registrations_mi_event_bucket}"]
  }
}

# Degrades Message Receiver Lambda
resource "aws_iam_role" "degrades_message_receiver_lambda" {
  name               = "degrades_message_receiver_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.degrades_message_receiver_lambda_assume_role.json
}

data "aws_iam_policy_document" "degrades_message_receiver_lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "degrades_message_receiver_lambda_dynamodb" {
  policy_arn = aws_iam_policy.degrades_message_table_access.arn
  role       = aws_iam_role.degrades_message_receiver_lambda.name
}

resource "aws_iam_policy" "degrades_message_table_access" {
  name   = "degrades_table_access_policy"
  policy = data.aws_iam_policy_document.degrades_message_table_access.json
}

resource "aws_iam_role_policy_attachment" "degrades_lambda_sqs_invoke" {
  policy_arn = aws_iam_policy.degrades_lambda_sqs_invoke.arn
  role       = aws_iam_role.degrades_message_receiver_lambda.name
}

resource "aws_iam_policy" "degrades_lambda_sqs_invoke" {
  name   = "degrades_sqs_invoke_policy"
  policy = data.aws_iam_policy_document.degrades_message_sqs_receive.json
}

data "aws_iam_policy_document" "degrade_message_receiver_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.degrades_message_receiver.arn}", "${aws_cloudwatch_log_group.degrades_message_receiver.arn}:*"]
  }
}

resource "aws_iam_policy" "degrades_message_receiver_logging" {
  name        = "degrades_message_receiver_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.degrade_message_receiver_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.degrades_message_receiver_lambda.name
  policy_arn = aws_iam_policy.degrades_message_receiver_logging.arn
}