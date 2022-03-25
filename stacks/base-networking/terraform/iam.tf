resource "aws_iam_role" "vpc_flow_log" {
  name               = "${var.environment}-data-pipeline-vpc-flow-log-assume-role"
  description        = "IAM Role for data pipeline VPC to allow writing to CloudWatch logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.vpc_flow_log_assume_role.arn
  ]
}


data "aws_iam_policy_document" "vpc_flow_log_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "vpc_flow_log_assume_role" {
  name   = "${var.environment}-data-pipeline-vpc-flow-create-logs-policy"
  policy = data.aws_iam_policy_document.vpc_flow_log.json
}

data "aws_iam_policy_document" "vpc_flow_log" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      aws_cloudwatch_log_group.vpc_flow_log.arn,
    ]
  }
}