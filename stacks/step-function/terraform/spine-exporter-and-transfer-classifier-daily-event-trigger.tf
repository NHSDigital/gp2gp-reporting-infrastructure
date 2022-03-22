resource "aws_cloudwatch_event_target" "event_trigger" {
  target_id = "${var.environment}-daily-spine-exporter-and-transfer-classifier-trigger"
  rule      = aws_cloudwatch_event_rule.run_daily_2am_cron_expression.name
  arn       = aws_sfn_state_machine.spine_exporter_and_transfer_classifier.arn
  role_arn  = aws_iam_role.spine_exporter_and_transfer_classifier_trigger.arn
}