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
          "title" : "SPINE_EXTRACT_ROW_COUNT",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by bin(1h) | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_ROW_COUNT'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "region" : var.region,
          "title" : "Details error messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'spine-exporter') and level != 'INFO'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "region" : var.region,
          "title" : "SPINE_EXTRACT_SIZE_BYTES",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(size_in_bytes) by bin(1h) | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_SIZE_BYTES'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "region" : var.region,
          "title" : "SPINE_EXTRACT_SIZE_BYTES",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) by bin(1d) | filter strcontains(@logStream, 'spine-exporter') and event='UPLOADED_CSV_TO_S3'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "region" : var.region,
          "title" : "SPINE_EXTRACT_SIZE_BYTES",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) by bin(1d) | filter strcontains(@logStream, 'spine-exporter') and event='FAILED_TO_RUN_MAIN'",
          "view" : "table"
        }
      },
    ]
  })
}