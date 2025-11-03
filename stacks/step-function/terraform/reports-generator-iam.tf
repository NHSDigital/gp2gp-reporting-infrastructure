data "aws_ssm_parameter" "reports_generator_task_definition_arn" {
  name = var.reports_generator_task_definition_arn_param_name
}

resource "aws_iam_role" "report_generator_step_function" {
  name               = "${var.environment}-reports-generator-step-function"
  description        = "StepFunction role for reports generator"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume.json
}

resource "aws_iam_role_policy_attachment" "report_generator_step_function" {
  role       = aws_iam_role.report_generator_step_function.name
  policy_arn = aws_iam_policy.report_generator_step_function.arn
}

resource "aws_iam_policy" "report_generator_step_function" {
  name   = "${var.environment}-reports-generator-step-function"
  policy = data.aws_iam_policy_document.report_generator_step_function.json
}

data "aws_ssm_parameter" "reports_generator_iam_role_arn" {
  name = var.reports_generator_iam_role_arn_param_name
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
      data.aws_ssm_parameter.reports_generator_iam_role_arn.value
    ]
  }
}

# Event trigger
resource "aws_iam_role" "reports_generator_trigger" {
  name               = "${var.environment}-reports-generator-trigger"
  description        = "Role used by EventBridge to trigger step function"
  assume_role_policy = data.aws_iam_policy_document.assume_event.json
}

resource "aws_iam_role_policy_attachment" "reports_generator_trigger" {
  role       = aws_iam_role.reports_generator_trigger.name
  policy_arn = aws_iam_policy.reports_generator_trigger.arn
}

resource "aws_iam_policy" "reports_generator_trigger" {
  name   = "${var.environment}-reports-generator-trigger"
  policy = data.aws_iam_policy_document.reports_generator_trigger.json
}

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
