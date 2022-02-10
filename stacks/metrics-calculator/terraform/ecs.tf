
data "aws_ssm_parameter" "metrics_calculator_repository_url" {
  name = var.metrics_calculator_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_ssm_parameter" "ods_metadata_input_bucket_name" {
  name = var.ods_metadata_input_bucket_param_name
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "metrics_calculator" {
  family = "${var.environment}-metrics-calculator"

  container_definitions = jsonencode([
    {
      name      = "metrics-calculator"
      image     = "${data.aws_ssm_parameter.metrics_calculator_repository_url.value}:${var.metrics_calculator_image_tag}"
      essential = true
      environment = [
        { "name" : "INPUT_TRANSFER_DATA_BUCKET", "value" : data.aws_ssm_parameter.transfers_input_bucket_name.value },
        { "name" : "ORGANISATION_METADATA_BUCKET", "value" : data.aws_ssm_parameter.ods_metadata_input_bucket_name.value },
        { "name" : "OUTPUT_METRICS_BUCKET", "value" : aws_s3_bucket.metrics_calculator.bucket }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "metrics-calculator/${var.metrics_calculator_image_tag}"
        }
      }
    },
  ])
  cpu                      = 1024
  memory                   = 6144
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-metrics-calculator"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.metrics_calculator.arn
}