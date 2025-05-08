resource "aws_cloudwatch_event_rule" "run_daily_5am_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-daily-5-30am"
  description         = "Eventbridge Event Rule that triggers the Daily Spine Export and Transfer Classifier Step function 5:37am every morning"
  schedule_expression = "cron(37 5 * * ? *)" // 5:37 ensures data is pulled outside of maintenance hours
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-eventbridge-event-rule"
      ApplicationRole = "AwsCloudwatchEventRule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_daily_7am_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-daily-7am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step function 7am every morning"
  schedule_expression = "cron(0 7 * * ? *)"
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-eventbridge-event-rule"
      ApplicationRole = "AwsCloudwatchEventRule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_once_a_month_on_15th_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-every-month-15th-7am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step Function and Dashboard Pipeline Step Function at 7am every month on the 15th"
  schedule_expression = "cron(0 7 15 * ? *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-eventbridge-event-rule"
      ApplicationRole = "AwsCloudwatchEventRule"
    }
  )
}

resource "aws_cloudwatch_event_rule" "run_once_a_week_on_monday_cron_expression" {
  name                = "${var.environment}-run-data-pipeline-step-functions-every-week-month-7am"
  description         = "Eventbridge Event Rule that triggers the Reports Generator Step Function at 7am every monday"
  schedule_expression = "cron(0 7 ? * 2 *)"
  is_enabled          = true
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-eventbridge-event-rule"
      ApplicationRole = "AwsCloudwatchEventRule"
    }
  )
}