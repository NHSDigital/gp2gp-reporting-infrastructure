data "aws_iam_policy_document" "degrades_lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "degrades_lambda_role" {
  name               = "${var.environment}_degrades_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.degrades_lambda_assume_role.json
}