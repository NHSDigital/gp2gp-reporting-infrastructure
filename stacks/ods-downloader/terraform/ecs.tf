data "aws_ssm_parameter" "ods_downloader_repo_url" {
  name = var.ods_downloader_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "ods_downloader" {
  family = "${var.environment}-ods-downloader"
  container_definitions = jsonencode([
    {
      name      = "ods-downloader"
      image     = "${data.aws_ssm_parameter.ods_downloader_repo_url.value}:${var.ods_downloader_image_tag}"
      essential = true
      environment = [
        { "name" : "MAPPING_BUCKET", "value" : aws_s3_bucket.ods_input.bucket },
        { "name" : "OUTPUT_BUCKET", "value" : aws_s3_bucket.ods_output.bucket }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
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
