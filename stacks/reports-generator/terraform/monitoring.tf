resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-reports-generator"
  dashboard_body = jsonencode({
    "start" : "-P3D"
    "widgets" : [
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Produced reports",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, `report-name`, `reporting-window-start-datetime`, `reporting-window-end-datetime`, `config-cutoff-days` | filter strcontains(@logStream, 'reports-generator') and strcontains(event,'PRODUCED_') | sort @timestamp",
          "view" : "table",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Percentage of technical failures",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, `report-name`, `percent_of_technical_failures`, `reporting-window-start-datetime`, `reporting-window-end-datetime`, `config-cutoff-days`, `total_technical_failures`, `total_transfers` | filter strcontains(@logStream, 'reports-generator') and event == 'PERCENTAGE_OF_TECHNICAL_FAILURES' | sort @timestamp",
          "view" : "table",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Successful upload count",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'reports-generator') and event='SUCCESSFULLY_UPLOADED_CSV_TO_S3'",
          "view" : "table",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Successful upload count - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'reports-generator') and event='SUCCESSFULLY_UPLOADED_CSV_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "timeSeries",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "FAILED_TO_RUN_MAIN",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) as count by bin(1d) as timestamp  | filter strcontains(@logStream, 'reports-generator') and event='FAILED_TO_RUN_MAIN'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Non-info logs (errors, warnings, system)",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'reports-generator') and level != 'INFO'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "All log messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'reports-generator')",
          "view" : "table",
        }
      },
    ]
  })
}