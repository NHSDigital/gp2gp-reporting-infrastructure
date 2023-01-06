data "aws_ssm_parameter" "reports_generator_repository_url" {
  name = var.reports_generator_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_ssm_parameter" "transfers_input_bucket_name" {
  name = var.transfers_input_bucket_param_name
}


data "aws_region" "current" {}

resource "aws_ecs_task_definition" "reports_generator" {
  family = "${var.environment}-reports-generator"

  container_definitions = jsonencode([
    {
      name      = "reports-generator"
      image     = "${data.aws_ssm_parameter.reports_generator_repository_url.value}:${var.reports_generator_image_tag}"
      essential = true
      environment = [
        { "name" : "INPUT_TRANSFER_DATA_BUCKET", "value" : data.aws_ssm_parameter.transfers_input_bucket_name.value },
        { "name" : "OUTPUT_REPORTS_BUCKET", "value" : aws_s3_bucket.reports_generator.bucket },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "reports-generator/${var.reports_generator_image_tag}"
        }
      }
    },
  ])
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-reports-generator"
      ApplicationRole = "AwsEcsTaskDefinition"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.reports_generator.arn
}