data "aws_ssm_parameter" "transfer_classifier_iam_role_arn" {
  name = var.transfer_classifier_iam_role_arn_param_name
}

data "aws_ssm_parameter" "transfer_classifier_task_definition_arn" {
  name = var.transfer_classifier_task_definition_arn_param_name
}

resource "aws_iam_role" "transfer_classifier_step_function" {
  name                = "${var.environment}-transfer-classifier-step-function"
  description         = "StepFunction role for transfer classifier"
  assume_role_policy  = data.aws_iam_policy_document.step_function_assume.json
  managed_policy_arns = [aws_iam_policy.transfer_classifier_step_function.arn]
}

resource "aws_iam_policy" "transfer_classifier_step_function" {
  name   = "${var.environment}-transfer-classifier-step-function"
  policy = data.aws_iam_policy_document.transfer_classifier_step_function.json
}

data "aws_iam_policy_document" "transfer_classifier_step_function" {
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
      data.aws_ssm_parameter.transfer_classifier_task_definition_arn.value
    ]
  }

  statement {
    sid = "StopEcsTask"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    resources = [
      data.aws_ssm_parameter.transfer_classifier_task_definition_arn.value
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
      "arn:aws:events:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }

  statement {
    sid = "PassIamRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      data.aws_ssm_parameter.execution_role_arn.value,
      data.aws_ssm_parameter.transfer_classifier_iam_role_arn.value
    ]
  }
}
