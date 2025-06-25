resource "aws_iam_role" "degrades_daily_summary_lambda" {
  name               = "degrades_daily_summary_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.degrades_daily_summary_lambda_assume_role.json
}

data "aws_iam_policy_document" "degrades_daily_summary_lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}