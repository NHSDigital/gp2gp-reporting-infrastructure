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

resource "aws_cloudwatch_event_target" "transfer_classifier_one_day_cutoff_event_target" {
  target_id = "${var.environment}-transfer-classifier-step-function"
  rule      = aws_cloudwatch_event_rule.transfer_classifier_event_rule.name
  arn       = aws_sfn_state_machine.transfer_classifier.arn
  role_arn  = aws_iam_role.transfer_classifier_trigger.arn
  input     = jsonencode({ "CONVERSATION_CUTOFF_DAYS" : 1, "OUTPUT_TRANSFER_DATA_BUCKET" : var.transfer_data_bucket_name })
}


resource "aws_cloudwatch_event_rule" "transfer_classifier_event_rule" {
  name                = "trigger-transfer-classifier-3am-every-morning"
  description         = "Cloudwatch Event Rule that triggers the Transfer Classifier Step Function at 3am every morning"
  schedule_expression = "cron(0 3 * * ? *)"

  tags = merge(
    local.common_tags,
    {
      Name = "Cloudwatch Event Rule"
    }
  )
}