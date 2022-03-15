resource "aws_cloudwatch_event_rule" "run_reports_once_a_month_cron_expression" {
  name                = "${var.environment}-reports-generator-every-15th-month-trigger"
  description         = "Cloudwatch Event Rule that triggers the Reports Generator Step Function every month on 15th"
  schedule_expression = "cron(0 4 15 * ? *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name = "Cloudwatch Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_target" "monthly_transfer_outcomes_per_supplier_pathway_report_event_trigger" {
  target_id = "${var.environment}-monthly-reports-generator-transfer-outcomes-trigger"
  rule      = aws_cloudwatch_event_rule.run_reports_once_a_month_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "TRANSFER_OUTCOMES_PER_SUPPLIER_PATHWAY",
    "CONVERSATION_CUTOFF_DAYS" : "14",
    "NUMBER_OF_MONTHS" : "1" })
}


resource "aws_cloudwatch_event_target" "monthly_ccg_level_integration_times_report_event_trigger" {
  target_id = "${var.environment}-monthly-reports-generator-ccg-level-integrations-trigger"
  rule      = aws_cloudwatch_event_rule.run_reports_once_a_month_cron_expression.name
  arn       = aws_sfn_state_machine.reports_generator.arn
  role_arn  = aws_iam_role.reports_generator_trigger.arn
  input = jsonencode({
    "REPORT_NAME" : "CCG_LEVEL_INTEGRATION_TIMES",
    "CONVERSATION_CUTOFF_DAYS" : "14",
    "NUMBER_OF_MONTHS" : "1" })
}