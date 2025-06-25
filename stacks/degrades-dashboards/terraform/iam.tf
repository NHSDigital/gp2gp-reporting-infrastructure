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

resource "aws_iam_role_policy_attachment" "degrades_api_lambda_s3_read" {
  role       = aws_iam_role.degrades_api_lambda_role.name
  policy_arn = aws_iam_policy.read_registrations_mi_events.arn
}

resource "aws_iam_policy" "read_registrations_mi_events" {
  name   = "${var.environment}-${var.degrades_api_lambda_name}"
  policy = data.aws_iam_policy_document.read_registrations_mi_events.json
}

data "aws_iam_policy_document" "read_registrations_mi_events" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]
    resources = [
    "arn:aws:s3:::${var.registrations_mi_event_bucket}/*", "arn:aws:s3:::${var.registrations_mi_event_bucket}"]
  }
}