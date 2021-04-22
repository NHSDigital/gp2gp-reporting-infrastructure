data "aws_ecr_repository" "ods_downloader" {
  name = data.aws_ssm_parameter.ods_downloader.value
}

data "aws_ssm_parameter" "ods_downloader" {
  name = var.ods_downloader_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

resource "aws_ecs_task_definition" "ods_downloader" {
  family = "${var.environment}-ods-downloader"
  container_definitions = jsonencode([
    {
      name  = "ods-downloader"
      image = "${data.aws_ecr_repository.ods_downloader.repository_url}:${var.ods_downloader_image_tag}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = var.region
          awslogs-stream-prefix = "ods-downloader/${var.ods_downloader_image_tag}"
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
    Name = "${var.environment}-ods-downloader"
  }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.ods_downloader.arn
}
