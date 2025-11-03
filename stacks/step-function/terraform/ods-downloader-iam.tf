resource "aws_iam_role" "ods_downloader_step_function" {
  name               = "${var.environment}-ods-downloader-step-function"
  description        = "StepFunction role for ODS Downloader"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume.json
}

resource "aws_iam_role_policy_attachment" "ods_downloader_step_function" {
  role       = aws_iam_role.ods_downloader_step_function.name
  policy_arn = aws_iam_policy.ods_downloader_step_function.arn
}

resource "aws_iam_policy" "ods_downloader_step_function" {
  name   = "${var.environment}-ods-downloader-step-function"
  policy = data.aws_iam_policy_document.ods_downloader_step_function.json
}

data "aws_iam_policy_document" "ods_downloader_step_function" {
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
    ]
  }
}

data "aws_ssm_parameter" "ods_downloader_iam_role_arn" {
  name = var.ods_downloader_iam_role_arn_param_name
}
