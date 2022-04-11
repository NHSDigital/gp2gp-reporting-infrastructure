resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-transfer-classifier"
  dashboard_body = jsonencode({
    "start" : "-P3D"
    "widgets" : [
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, row_count, metadata.cutoff-days, metadata.start-datetime, metadata.end-datetime | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by bin(1h) | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT'",
          "view" : "timeSeries"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "Successful upload count",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'transfer-classifier') and event='SUCCESSFULLY_UPLOADED_PARQUET_TO_S3'",
          "view" : "table",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "Successful upload count - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'transfer-classifier') and event='SUCCESSFULLY_UPLOADED_PARQUET_TO_S3'",
          "view" : "timeSeries",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "FAILED_TO_RUN_MAIN",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'transfer-classifier') and event='FAILED_TO_RUN_MAIN'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "Detailed error messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'transfer-classifier') and level == 'ERROR'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "Non-info logs (errors, warnings, system)",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'transfer-classifier') and level != 'INFO'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "All log messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'transfer-classifier')",
          "view" : "table",
        }
      },
    ]
  })
}