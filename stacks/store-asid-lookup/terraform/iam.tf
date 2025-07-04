data "aws_iam_policy_document" "store_asid_lookup_lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "store_asid_lookup_lambda" {
  name               = "${var.environment}-store-asid-lookup-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.store_asid_lookup_lambda_assume_role.json
}

resource "aws_iam_policy" "store_asid_lookup_lambda_policy" {
  name        = "${var.environment}-store-asid-lookup-lambda-policy"
  description = "IAM policy for Store ASID Lookup Lambda"

  policy = jsonencode({
    version = "2012-10-17"
    statement = [
      {
        effect = "Allow"
        action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        resources = ["${aws_cloudwatch_log_group.store_asid_lookup.arn}"]
      },
      {
        effect = "Allow"
        action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        resources = [
          "${var.gp2gp_inbox_storage_bucket_arn}/*"
        ]
      },
      {
        effect = "Allow"
        action = [
          "s3:ListBucket"
        ]
        resources = [
          var.gp2gp_inbox_storage_bucket_arn
        ]
      },
      {
        effect = "Allow"
        action = [
          "s3:PutObject",
        ]
        resources = [
          "${var.gp2gp_asid_lookup_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "store_asid_lookup_lambda_policy" {
  policy_arn = aws_iam_policy.store_asid_lookup_lambda_policy.arn
  role       = aws_iam_role.store_asid_lookup_lambda.name
}
