data "aws_ssm_parameter" "spine_exporter_repo_url" {
  name = var.spine_exporter_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_ssm_parameter" "splunk_url" {
  name = var.splunk_url_param_name
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "spine_exporter" {
  family = "${var.environment}-spine-exporter"
  container_definitions = jsonencode([
    {
      name      = "spine-exporter"
      image     = "${data.aws_ssm_parameter.spine_exporter_repo_url.value}:${var.spine_exporter_image_tag}"
      essential = true
      environment = [
        { "name" : "SPLUNK_URL", "value" : data.aws_ssm_parameter.splunk_url.value },
        { "name" : "SPLUNK_API_TOKEN_PARAM_NAME", "value" : var.splunk_api_token_param_name },
        { "name" : "OUTPUT_SPINE_DATA_BUCKET", "value" : aws_s3_bucket.spine_exporter.bucket }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "spine-exporter/${var.spine_exporter_image_tag}"
        }
      }
    }
  ])
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-spine-exporter"
      ApplicationRole = "AwsEcsTaskDefinition"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.spine_exporter.arn
}
