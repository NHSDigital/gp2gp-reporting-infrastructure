resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-spine-exporter"
  dashboard_body = jsonencode({
    "start" : "-P3D"
    "widgets" : [
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "region" : var.region,
          "title" : "Count of errors grouped by error type and hour",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.name}' | fields @timestamp, error | filter ispresent(error) | stats count(*) as totalCount by error, bin (1h) as timeframe",
          "view" : "table"
        }
      },
    ]
  })
}
