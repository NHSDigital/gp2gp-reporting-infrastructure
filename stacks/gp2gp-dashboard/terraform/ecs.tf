data "aws_ssm_parameter" "gp2gp_dashboard_repository_url" {
  name = var.gp2gp_dashboard_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

resource "aws_ecs_task_definition" "gp2gp_dashboard" {
  family = "${var.environment}-gp2gp-dashboard"

  container_definitions = jsonencode([
    {
      name      = "gp2gp-dashboard"
      image     = "${data.aws_ssm_parameter.gp2gp_dashboard_repository_url.value}:${var.gp2gp_dashboard_image_tag}"
      essential = true
      environment = [
        { "name" : "DEPLOYMENT_BUCKET", "value" : aws_s3_bucket.dashboard_website.bucket },
        { "name" : "GATSBY_ENV", value : var.environment },
        { "name" : "DEPLOYMENT_ENV", value : var.environment },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "gp2gp-dashboard/${var.gp2gp_dashboard_image_tag}"
        }
      }
    },
  ])
  cpu                      = 2048
  memory                   = 4096
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-gp2gp-dashboard"
      ApplicationRole = "AwsEcsTaskDefinition"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.gp2gp_dashboard.arn
}