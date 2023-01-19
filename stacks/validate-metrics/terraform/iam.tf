resource "aws_iam_role" "validate_metrics_lambda_role" {
  name               = "${var.environment}-validate_metrics-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.validate_metrics_lambda_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.validate_metrics_lambda_ssm_access.arn,
#    aws_iam_policy.validate_metrics_cloudwatch_log_access.arn,
#    aws_iam_policy.metrics_input_bucket_read_access.arn,
  ]
}

resource "aws_iam_policy" "validate_metrics_lambda_ssm_access" {
  name   = "${var.environment}-validate-metrics-ssm--access"
  policy = data.aws_iam_policy_document.validate_metrics_lambda_ssm_access.json
}

data "aws_iam_policy_document" "validate_metrics_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "validate_metrics_lambda_ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.s3_national_metrics_filepath_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.s3_practice_metrics_filepath_param_name}",
    ]
  }
}