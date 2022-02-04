data "aws_ssm_parameter" "transfers_input_bucket_name" {
  name = var.transfers_input_bucket_param_name
}

data "aws_ssm_parameter" "transfers_input_bucket_read_access_arn" {
  name = var.transfer_input_bucket_read_access_param_name
}

resource "aws_iam_role" "reports_generator" {
  name               = "${var.environment}-registrations-reports-generator"
  description        = "Role for reports generator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    data.aws_ssm_parameter.transfers_input_bucket_read_access_arn.value,
    aws_iam_policy.reports_generator_output_buckets_write_access.arn,
    aws_iam_policy.notebook_data_bucket_read_access.arn
  ]
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = [
    "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "reports_generator_output_buckets_write_access" {
  name   = "reports-generator-output-buckets-${var.environment}-write"
  policy = data.aws_iam_policy_document.reports_generator_output_buckets_write_access.json
}

data "aws_iam_policy_document" "reports_generator_output_buckets_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.reports_generator.bucket}/*",
      "arn:aws:s3:::${var.notebook_data_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "notebook_data_bucket_read_access" {
  name   = "${var.notebook_data_bucket_name}-read"
  policy = data.aws_iam_policy_document.notebook_data_output_bucket_read_access.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "notebook_data_output_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.notebook_data_bucket_name}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.notebook_data_bucket_name}/*"
    ]
  }
}

# Step Function IAM
resource "aws_iam_role" "report_generator_step_function" {
  name                = "${var.environment}-reports-generator-step-function"
  description         = "StepFunction role for reports generator"
  assume_role_policy  = data.aws_iam_policy_document.step_function_assume.json
  managed_policy_arns = [aws_iam_policy.report_generator_step_function.arn]
}

resource "aws_iam_policy" "report_generator_step_function" {
  name   = "${var.environment}-reports-generator-step-function"
  policy = data.aws_iam_policy_document.report_generator_step_function.json
}

data "aws_iam_policy_document" "report_generator_step_function" {
  statement {
    sid = "GetEcrAuthToken"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "RunEcsTask"
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      data.aws_ssm_parameter.reports_generator_task_definition_arn.value
    ]
  }

  statement {
    sid = "StopEcsTask"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    resources = [
      data.aws_ssm_parameter.reports_generator_task_definition_arn.value
    ]
  }

  statement {
    sid = "StepFunctionRule"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }

  statement {
    sid = "PassIamRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      data.aws_ssm_parameter.execution_role_arn.value,
      aws_iam_role.reports_generator.arn
    ]
  }
}

data "aws_iam_policy_document" "step_function_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com"
      ]
    }
  }
}

data "aws_caller_identity" "current" {}

# Event trigger
data "aws_iam_policy_document" "reports_generator_trigger" {
  statement {
    sid = "TriggerStepFunction"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.reports_generator.arn
    ]
  }
}

resource "aws_iam_policy" "reports_generator_trigger" {
  name   = "${var.environment}-reports-generator-trigger"
  policy = data.aws_iam_policy_document.reports_generator_trigger.json
}

resource "aws_iam_role" "reports_generator_trigger" {
  name                = "${var.environment}-reports-generator-trigger"
  description         = "Role used by EventBridge to trigger step function"
  assume_role_policy  = data.aws_iam_policy_document.assume_event.json
  managed_policy_arns = [aws_iam_policy.reports_generator_trigger.arn]
}

data "aws_iam_policy_document" "assume_event" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}
