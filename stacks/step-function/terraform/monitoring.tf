resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-overview"
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
          "title" : "FAILED_TO_RUN_MAIN",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) as count by bin(1d) as timestamp  | filter event='FAILED_TO_RUN_MAIN'",
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
          "title" : "Errors and system logs (errors, system)",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, @message, message, @logStream | filter level != 'INFO' | filter level != 'WARNING'",
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
          "title" : "Successful upload count [spine-exporter] - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'spine-exporter') and event='UPLOADED_CSV_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "bar",
        }
        }, {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "Successful upload count [transfer-classifier] - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'transfer-classifier') and event='SUCCESSFULLY_UPLOADED_PARQUET_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "bar",
        }
        }, {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "Successful upload count [metrics-calculator] - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'metrics-calculator') and event='UPLOADED_JSON_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "bar",
        }
        }, {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "Successful upload count [reports-generator] - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'reports-generator') and event='SUCCESSFULLY_UPLOADED_CSV_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "bar",
        }
        }, {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.region,
          "title" : "Successful upload count [ods-downloader] - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  fields strcontains(@logStream, 'ods-downloader') and event='UPLOADED_JSON_TO_S3' as has_event | stats sum(has_event) by bin(1d) | sort @timestamp",
          "view" : "bar",
        }
      },
    ]
  })
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}
