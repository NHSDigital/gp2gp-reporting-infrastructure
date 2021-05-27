
data "aws_ssm_parameter" "platform_metrics_calculator_repository_url" {
  name = var.platform_metrics_calculator_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "platform_metrics_calculator" {
  family = "${var.environment}-platform-metrics-calculator"

  container_definitions = jsonencode([
    {
      name      = "platform-metrics-calculator"
      image     = "${data.aws_ssm_parameter.platform_metrics_calculator_repository_url.value}:${var.platform_metrics_calculator_image_tag}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "platform-metric-calculator/${var.platform_metrics_calculator_image_tag}"
        }
      }
    },
  ])
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-platform-metrics-calculator"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.platform_metrics_calculator.arn
}