resource "aws_iam_role" "data_pipeline_step_function" {
  name                = "${var.environment}-data-pipeline-step-function"
  description         = "StepFunction role for data pipeline"
  assume_role_policy  = data.aws_iam_policy_document.step_function_assume.json
  managed_policy_arns = [aws_iam_policy.data_pipeline_step_function.arn]
}

resource "aws_iam_policy" "data_pipeline_step_function" {
  name   = "${var.environment}-data-pipeline-step-function"
  policy = data.aws_iam_policy_document.data_pipeline_step_function.json
}

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
      data.aws_ssm_parameter.ods_downloader_task_definition_arn.value,
      data.aws_ssm_parameter.metrics_calculator_task_definition_arn.value
    ]
  }

  statement {
    sid = "StopEcsTask"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    resources = [
      data.aws_ssm_parameter.ods_downloader_task_definition_arn.value,
      data.aws_ssm_parameter.metrics_calculator_task_definition_arn.value
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
      data.aws_ssm_parameter.ods_downloader_iam_role_arn.value,
      data.aws_ssm_parameter.metrics_calculator_iam_role_arn.value
    ]
  }
}

data "aws_ssm_parameter" "ods_downloader_iam_role_arn" {
  name = var.ods_downloader_iam_role_arn_param_name
}

data "aws_ssm_parameter" "metrics_calculator_iam_role_arn" {
  name = var.metrics_calculator_iam_role_arn_param_name
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
  name                = "${var.environment}-data-pipeline-trigger"
  description         = "Role used by EventBridge to trigger step function"
  assume_role_policy  = data.aws_iam_policy_document.assume_event.json
  managed_policy_arns = [aws_iam_policy.data_pipeline_trigger.arn]
}
