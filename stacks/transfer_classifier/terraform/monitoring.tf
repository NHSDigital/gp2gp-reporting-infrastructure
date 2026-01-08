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
          "region" : data.aws_region.current.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, row_count, `metadata.cutoff-days`, `metadata.start-datetime`, `metadata.end-datetime` | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT: 1 day cutoff - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by time | sort time | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT' and `metadata.cutoff-days` == 1",
          "view" : "bar",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT: 2 day cutoff - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by time | sort time | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT' and `metadata.cutoff-days` == 2",
          "view" : "bar",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "TRANSFER_CLASSIFIER_ROW_COUNT: 1 day cutoff - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by time | sort time | filter strcontains(@logStream, 'transfer-classifier') and event='TRANSFER_CLASSIFIER_ROW_COUNT' and `metadata.cutoff-days` == 14",
          "view" : "bar",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
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
          "region" : data.aws_region.current.region,
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
          "region" : data.aws_region.current.region,
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
          "region" : data.aws_region.current.region,
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
          "region" : data.aws_region.current.region,
          "title" : "All log messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'transfer-classifier')",
          "view" : "table",
        }
      },
    ]
  })
}
