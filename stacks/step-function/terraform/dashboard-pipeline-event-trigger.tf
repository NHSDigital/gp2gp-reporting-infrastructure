resource "aws_cloudwatch_event_target" "monthly_dashboard_pipeline_event_trigger" {
  target_id = "${var.environment}-monthly-dashboard-pipeline-trigger"
  rule      = aws_cloudwatch_event_rule.run_once_a_month_on_15th_cron_expression.name
  arn       = aws_sfn_state_machine.dashboard_pipeline.arn
  role_arn  = aws_iam_role.dashboard_pipeline_trigger.arn
  input = jsonencode({
    "SKIP_DASHBOARD_PIPELINE_GOCD_TRIGGER" : var.environment == "dev" ? true : false
  })
}
