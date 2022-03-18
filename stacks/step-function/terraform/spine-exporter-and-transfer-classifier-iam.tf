data "aws_ssm_parameter" "spine_exporter_task_definition_arn" {
  name = var.spine_exporter_task_definition_arn_param_name
}

data "aws_ssm_parameter" "spine_exporter_iam_role_arn" {
  name = var.spine_exporter_iam_role_arn_param_name
}

resource "aws_iam_role" "spine_exporter_and_transfer_classifier_step_function" {
  name                = "${var.environment}-daily-spine-exporter-and-transfer-classifier-step-function"
  description         = "StepFunction role for spine exporter and transfer classifier"
  assume_role_policy  = data.aws_iam_policy_document.step_function_assume.json
  managed_policy_arns = [
    aws_iam_policy.spine_exporter_step_function.arn,
    aws_iam_policy.transfer_classifier_step_function.arn
  ]
}

resource "aws_iam_policy" "spine_exporter_step_function" {
  name   = "${var.environment}-daily-spine-exporter-step-function"
  policy = data.aws_iam_policy_document.spine_exporter_step_function.json
}

data "aws_iam_policy_document" "spine_exporter_step_function" {
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
      data.aws_ssm_parameter.spine_exporter_task_definition_arn.value,
    ]
  }

  statement {
    sid = "StopEcsTask"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    resources = [
      data.aws_ssm_parameter.spine_exporter_task_definition_arn.value,
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
      data.aws_ssm_parameter.spine_exporter_iam_role_arn.value,
    ]
  }
}

# Event trigger
data "aws_iam_policy_document" "spine_exporter_and_transfer_classifier_trigger" {
  statement {
    sid = "TriggerStepFunction"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.spine_exporter_and_transfer_classifier.arn
    ]
  }
}

resource "aws_iam_policy" "spine_exporter_and_transfer_classifier_trigger" {
  name   = "${var.environment}-daily-spine-exporter-and-transfer-classifier-trigger"
  policy = data.aws_iam_policy_document.spine_exporter_and_transfer_classifier_trigger.json
}

resource "aws_iam_role" "spine_exporter_and_transfer_classifier_trigger" {
  name                = "${var.environment}-daily-spine-exporter-and-transfer-classifier-trigger"
  description         = "Role used by EventBridge to trigger step function"
  assume_role_policy  = data.aws_iam_policy_document.assume_event.json
  managed_policy_arns = [aws_iam_policy.spine_exporter_and_transfer_classifier_trigger.arn]
}
# /Event trigger