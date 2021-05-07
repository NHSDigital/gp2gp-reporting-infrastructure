resource "aws_iam_role" "data_pipeline_step_function" {
  name               = "${var.environment}-data-pipeline-step-function"
  description        = "StepFunction role for data pipeline"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume.json
}

resource "aws_iam_role_policy_attachment" "step_function_data_pipeline" {
  role       = aws_iam_role.data_pipeline_step_function.name
  policy_arn = aws_iam_policy.data_pipeline_step_function.arn
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

resource "aws_iam_policy" "data_pipeline_step_function" {
  name   = "${var.environment}-data-pipeline-step-function"
  policy = data.aws_iam_policy_document.data_pipeline_step_function.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "data_pipeline_step_function" {
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
      data.aws_ssm_parameter.ods_downloader_task_definition_arn.value
    ]
  }

  statement {
    sid = "StopEcsTask"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    resources = [
      data.aws_ssm_parameter.ods_downloader_task_definition_arn.value
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
      "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }

  statement {
    sid = "PassIamRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      data.aws_ssm_parameter.execution_role_arn.value,
      data.aws_ssm_parameter.ods_downloader_iam_role_arn.value
    ]
  }
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.data_pipeline_execution_role_arn_param_name
}

data "aws_ssm_parameter" "ods_downloader_iam_role_arn" {
  name = var.ods_downloader_iam_role_arn_param_name
}

data "aws_iam_policy_document" "data_pipeline_trigger" {
  statement {
    sid = "TriggerStepFunction"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.data_pipeline.arn
    ]
  }
}

resource "aws_iam_policy" "data_pipeline_trigger" {
  name   = "${var.environment}-data-pipeline-trigger"
  policy = data.aws_iam_policy_document.data_pipeline_trigger.json
}

resource "aws_iam_role" "data_pipeline_trigger" {
  name               = "${var.environment}-data-pipeline-trigger"
  assume_role_policy = data.aws_iam_policy_document.assume_event.json
}

resource "aws_iam_role_policy_attachment" "data_pipeline_trigger" {
  role       = aws_iam_role.data_pipeline_trigger.name
  policy_arn = aws_iam_policy.data_pipeline_trigger.arn
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