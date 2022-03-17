resource "aws_cloudwatch_event_rule" "daily_cron_expression" {
  name                = "${var.environment}-run-daily-spine-exporter-and-transfer-classifier-2am"
  description         = "Cloudwatch Event Rule that triggers the Daily Spine Export and Transfer Classifier Step function 2am every morning"
  schedule_expression = "cron(0 2 * * ? *)"

  tags = merge(
    local.common_tags,
    {
      Name = "Cloudwatch Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_target" "event_trigger" {
  target_id = "${var.environment}-daily-spine-exporter-and-transfer-classifier-trigger"
  rule      = aws_cloudwatch_event_rule.daily_cron_expression.name
  arn       = aws_sfn_state_machine.spine_exporter_and_transfer_classifier.arn
  role_arn  = aws_iam_role.spine_exporter_and_transfer_classifier_trigger.arn
}