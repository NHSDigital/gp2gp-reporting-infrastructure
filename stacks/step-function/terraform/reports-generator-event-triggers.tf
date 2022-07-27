resource "aws_cloudwatch_event_target" "monthly_transfer_outcomes_per_supplier_pathway_report_event_trigger" {
  target_id = "${var.environment}-monthly-reports-generator-transfer-outcomes-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_month_on_15th_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_OUTCOMES_PER_SUPPLIER_PATHWAY",
    "CONVERSATION_CUTOFF_DAYS" : "14",
  "NUMBER_OF_MONTHS" : "1" })
}


resource "aws_cloudwatch_event_target" "monthly_sicbl_level_integration_times_report_event_trigger" {
  target_id = "${var.environment}-monthly-reports-generator-sicbl-level-integr-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_month_on_15th_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "SUB_ICB_LOCATION_LEVEL_INTEGRATION_TIMES",
    "CONVERSATION_CUTOFF_DAYS" : "14",
  "NUMBER_OF_MONTHS" : "1" })
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

resource "aws_cloudwatch_event_target" "weekly_transfer_details_by_hour_report_event_trigger" {
  target_id = "${var.environment}-weekly-reports-generator-transfer-hourly-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_week_on_monday_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_DETAILS_BY_HOUR",
    "CONVERSATION_CUTOFF_DAYS" : "2",
    "NUMBER_OF_DAYS" : "7" })
}

resource "aws_cloudwatch_event_target" "daily_transfer_outcomes_per_supplier_pathway_report_event_trigger" {
  target_id = "${var.environment}-daily-reports-generator-transfer-outcomes-trigger"
  rule      = aws_cloudwatch_event_rule.run_daily_4am_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_OUTCOMES_PER_SUPPLIER_PATHWAY",
    "CONVERSATION_CUTOFF_DAYS" : "0",
    "NUMBER_OF_DAYS" : "1",
    "ALERT_ENABLED": "true"
  })
}