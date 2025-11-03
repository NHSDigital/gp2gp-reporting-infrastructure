resource "aws_iam_role" "validate_metrics_lambda_role" {
  name               = "${var.environment}-validate-metrics-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.validate_metrics_lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "validate_metrics_lambda_ssm_access" {
  role       = aws_iam_role.validate_metrics_lambda_role.name
  policy_arn = aws_iam_policy.validate_metrics_lambda_ssm_access.arn
}

resource "aws_iam_role_policy_attachment" "validate_metrics_lambda_cloudwatch_log_access" {
  role       = aws_iam_role.validate_metrics_lambda_role.name
  policy_arn = aws_iam_policy.validate_metrics_cloudwatch_log_access.arn
}

resource "aws_iam_role_policy_attachment" "validate_metrics_lambda_metrics_input_bucket_read_access" {
  role       = aws_iam_role.validate_metrics_lambda_role.name
  policy_arn = aws_iam_policy.metrics_input_bucket_read_access.arn
}

data "aws_ssm_parameter" "metrics_input_bucket_name" {
  name = var.metrics_calculator_bucket_param_name
}

resource "aws_iam_policy" "metrics_input_bucket_read_access" {
  name   = "${var.environment}-${data.aws_ssm_parameter.metrics_input_bucket_name.value}-read"
  policy = data.aws_iam_policy_document.metrics_input_bucket_read_access.json
}

data "aws_iam_policy_document" "metrics_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.metrics_input_bucket_name.value}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${data.aws_ssm_parameter.metrics_input_bucket_name.value}/*"
    ]
  }
}


resource "aws_iam_policy" "validate_metrics_lambda_ssm_access" {
  name   = "${var.environment}-validate-metrics-ssm-access"
  policy = data.aws_iam_policy_document.validate_metrics_lambda_ssm_access.json
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
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.metrics_calculator_bucket_param_name}",
    ]
  }
}

resource "aws_iam_policy" "validate_metrics_cloudwatch_log_access" {
  name   = "${var.environment}-validate-metrics-cloudwatch-log--access"
  policy = data.aws_iam_policy_document.validate_metrics-cloudwatch-log-access.json
}


data "aws_iam_policy_document" "validate_metrics-cloudwatch-log-access" {
  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.validate_metrics_logs_group.arn}:*",
    ]
  }
}

resource "aws_cloudwatch_log_group" "validate_metrics_logs_group" {
  name = "/aws/lambda/${var.environment}-${var.validate_metrics_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-${var.validate_metrics_lambda_name}"
      ApplicationRole = "AwsCloudwatchLogGroup"
    }
  )
  retention_in_days = 60
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