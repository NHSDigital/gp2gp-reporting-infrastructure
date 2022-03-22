resource "aws_iam_role" "dashboard_pipeline_step_function" {
  name                = "${var.environment}-dashboard-pipeline-step-function"
  description         = "StepFunction role for dashboard pipeline (responsible for deploying FE)"
  assume_role_policy  = data.aws_iam_policy_document.step_function_assume.json
  managed_policy_arns = [aws_iam_policy.dashboard_pipeline_step_function.arn]
}

resource "aws_iam_policy" "dashboard_pipeline_step_function" {
  name   = "${var.environment}-dashboard-pipeline-step-function"
  policy = data.aws_iam_policy_document.dashboard_pipeline_step_function.json
}

data "aws_iam_policy_document" "dashboard_pipeline_step_function" {
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
      data.aws_ssm_parameter.metrics_calculator_iam_role_arn.value
    ]
  }
}

data "aws_ssm_parameter" "metrics_calculator_iam_role_arn" {
  name = var.metrics_calculator_iam_role_arn_param_name
}


# Event trigger
resource "aws_iam_role" "dashboard_pipeline_trigger" {
  name                = "${var.environment}-dashboard-pipeline-trigger"
  description         = "Role used by EventBridge to trigger step function"
  assume_role_policy  = data.aws_iam_policy_document.assume_event.json
  managed_policy_arns = [aws_iam_policy.dashboard_pipeline_trigger.arn]
}

resource "aws_iam_policy" "dashboard_pipeline_trigger" {
  name   = "${var.environment}-dashboard-pipeline-trigger"
  policy = data.aws_iam_policy_document.dashboard_pipeline_trigger.json
}

data "aws_iam_policy_document" "dashboard_pipeline_trigger" {
  statement {
    sid = "TriggerStepFunction"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.dashboard_pipeline.arn
    ]
  }
}


