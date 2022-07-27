resource "aws_cloudwatch_event_rule" "run_daily_2am_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-daily-2am"
  description         = "Eventbridge Event Rule that triggers the Daily Spine Export and Transfer Classifier Step function 2am every morning"
  schedule_expression = "cron(0 2 * * ? *)"

  tags = merge(
    local.common_tags,
    {
      Name = "Eventbridge Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_daily_4am_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-daily-4am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step function 4am every morning"
  schedule_expression = "cron(0 4 * * ? *)"

  tags = merge(
    local.common_tags,
    {
      Name = "Eventbridge Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_once_a_month_on_15th_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-every-month-15th-4am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step Function and Dashboard Pipeline Step Function every month on 15th"
  schedule_expression = "cron(0 4 15 * ? *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name = "Eventbridge Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_once_a_week_on_monday_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-every-week-month-4am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step Function at 4am every monday"
  schedule_expression = "cron(0 4 ? * 2 *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name = "Eventbridge Event Rule"
    }
  )
}