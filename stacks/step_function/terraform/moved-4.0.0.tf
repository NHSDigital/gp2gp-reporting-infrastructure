moved {
  from = aws_cloudwatch_event_target.monthly_transfer_outcomes_per_supplier_pathway_report_event_trigger
  to   = aws_cloudwatch_event_target.monthly_transfer_outcomes_per_supplier_pathway_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.monthly_sicbl_level_integration_times_report_event_trigger
  to   = aws_cloudwatch_event_target.monthly_sicbl_level_integration_times_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.weekly_transfer_outcomes_per_supplier_pathway_report_event_trigger
  to   = aws_cloudwatch_event_target.weekly_transfer_outcomes_per_supplier_pathway_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.weekly_transfer_level_technical_failures_report_event_trigger
  to   = aws_cloudwatch_event_target.weekly_transfer_level_technical_failures_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.weekly_transfer_details_by_hour_report_event_trigger
  to   = aws_cloudwatch_event_target.weekly_transfer_details_by_hour_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.daily_transfer_outcomes_per_supplier_pathway_report_event_trigger
  to   = aws_cloudwatch_event_target.daily_transfer_outcomes_per_supplier_pathway_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.daily_transfer_level_technical_failures_report_event_trigger
  to   = aws_cloudwatch_event_target.daily_transfer_level_technical_failures_report_event_trigger[0]
}

moved {
  from = aws_cloudwatch_event_target.daily_transfer_details_by_hour_report_event_trigger
  to   = aws_cloudwatch_event_target.daily_transfer_details_by_hour_report_event_trigger[0]
}
