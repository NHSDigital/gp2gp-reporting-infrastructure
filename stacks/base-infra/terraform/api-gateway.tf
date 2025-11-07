# Allows API gateway to log to Cloudwatch which is an account level setting
resource "aws_api_gateway_account" "api_gateway" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch_role.arn
}


data "aws_iam_policy_document" "assume_iam_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "api-gateway-cloudwatch"
  description        = "API gateway role to allow for cloudwatch logging"
  assume_role_policy = data.aws_iam_policy_document.assume_iam_role.json
}

data "aws_iam_policy_document" "cloudwatch_iam_policy" {
  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_role_policy" {
  name   = "api-gateway-cloudwatch-access"
  role   = aws_iam_role.cloudwatch_role.id
  policy = data.aws_iam_policy_document.cloudwatch_iam_policy.json
}
