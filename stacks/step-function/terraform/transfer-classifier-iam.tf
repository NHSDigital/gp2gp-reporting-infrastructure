data "aws_ssm_parameter" "transfer_classifier_iam_role_arn" {
  name = var.transfer_classifier_iam_role_arn_param_name
}

resource "aws_iam_policy" "transfer_classifier_trigger" {
  name   = "${var.environment}-transfer-classifier-trigger"
  policy = data.aws_iam_policy_document.transfer_classifier_trigger.json
}

data "aws_iam_policy_document" "transfer_classifier_trigger" {
  statement {
    sid = "TriggerStepFunction"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.transfer_classifier.arn
    ]
  }
}

resource "aws_iam_role" "transfer_classifier_trigger" {
  name                = "${var.environment}-transfer-classifier-trigger"
  description         = "Role used by EventBridge to trigger transfer classifier step function"
  assume_role_policy  = data.aws_iam_policy_document.assume_event.json
  managed_policy_arns = [aws_iam_policy.transfer_classifier_trigger.arn]
}