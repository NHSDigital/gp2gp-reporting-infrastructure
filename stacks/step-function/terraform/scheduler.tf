resource "aws_cloudwatch_event_target" "data_pipeline" {
  target_id = "${var.environment}-data-pipeline"
  rule      = aws_cloudwatch_event_rule.run_once_a_month_cron_expression.id
  arn       = aws_sfn_state_machine.data_pipeline.arn
  role_arn  = aws_iam_role.data_pipeline_trigger.arn
  input_transformer {
    input_paths = {
      "time" : "$.time"
    }
    input_template = replace(replace(jsonencode({
      "time" : "<time>"
    }), "\\u003e", ">"), "\\u003c", "<")
  }
}

resource "aws_cloudwatch_event_rule" "run_once_a_month_cron_expression" {
  name                = "${var.environment}-data-pipeline-trigger"
  description         = "Trigger Step Function with the cron expression"
  schedule_expression = "cron(0/0 1 15 * ? *)"
  is_enabled          = false
  tags                = local.common_tags
}