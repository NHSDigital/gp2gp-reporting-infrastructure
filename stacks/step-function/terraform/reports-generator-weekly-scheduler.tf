resource "aws_cloudwatch_event_rule" "run_once_a_week_on_monday_cron_expression" {
  name                = "${var.environment}-reports-generator-4am-every-monday-trigger"
  description         = "Cloudwatch Event Rule that triggers the Reports Generator Step Function at 4am every monday"
  schedule_expression = "cron(0 4 ? * 2 *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name = "Cloudwatch Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_target" "weekly_transfer_outcomes_per_supplier_pathway_report_event_trigger" {
  target_id = "${var.environment}-weekly-reports-generator-transfer-outcomes-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_week_on_monday_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_OUTCOMES_PER_SUPPLIER_PATHWAY",
    "CONVERSATION_CUTOFF_DAYS" : "2",
  "NUMBER_OF_DAYS" : "7" })
}

resource "aws_cloudwatch_event_target" "weekly_transfer_level_technical_failures_report_event_trigger" {
  target_id = "${var.environment}-weekly-reports-generator-transfer-level-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_week_on_monday_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_LEVEL_TECHNICAL_FAILURES",
    "CONVERSATION_CUTOFF_DAYS" : "2",
  "NUMBER_OF_DAYS" : "7" })
}