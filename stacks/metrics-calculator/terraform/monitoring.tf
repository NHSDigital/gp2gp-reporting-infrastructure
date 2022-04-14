resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-metrics-calculator"
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
          "title" : "Successful upload count",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'metrics-calculator') and event='UPLOADED_JSON_TO_S3'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | sort timestamp | filter strcontains(@logStream, 'metrics-calculator') and event='UPLOADED_JSON_TO_S3'",
          "view" : "bar",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : var.region,
          "title" : "National metrics stats",
          "query" : <<EOT
              SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}'
              | fields @timestamp, @integratedOnTimePercentage, @technicalFailurePercentage
              | parse data "{'year': *, 'month': *," as year, month
              | parse data "'integratedOnTime': {'transferCount': *, 'transferPercentage': *}" as integratedOnTime, @integratedOnTimePercentage
              | parse data "'technicalFailure': {'transferCount': *, 'transferPercentage': *}" as technicalFailure, @technicalFailurePercentage
              | parse data "transferCount': *," as transferCount
              | filter strcontains(@logStream, 'metrics-calculator') and event='UPLOADED_JSON_TO_S3' and ispresent(data)
            EOT
          "view" : "log",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'metrics-calculator') and level == 'ERROR'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'metrics-calculator') and level != 'INFO'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'metrics-calculator')",
          "view" : "table",
        }
      },
    ]
  })
}