data "aws_ssm_parameter" "transfer_classifier_repository_url" {
  name = var.transfer_classifier_repo_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_ssm_parameter" "execution_role_arn" {
  name = var.execution_role_arn_param_name
}

data "aws_ssm_parameter" "ods_metadata_input_bucket_name" {
  name = var.ods_metadata_bucket_param_name
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" transfer_classifier {
  family = "${var.environment}-transfer-classifier"

  container_definitions = jsonencode([
    {
      name      = "transfer-classifier"
      image     = "${data.aws_ssm_parameter.transfer_classifier_repository_url.value}:${var.transfer_classifier_image_tag}"
      essential = true
      environment = [
        { "name" : "INPUT_SPINE_DATA_BUCKET", "value" : data.aws_ssm_parameter.spine_messages_bucket_name.value },
        { "name" : "OUTPUT_TRANSFER_DATA_BUCKET", "value" : aws_s3_bucket.transfer_classifier.bucket },
        { "name" : "INPUT_ODS_METADATA_BUCKET", "value" : data.aws_ssm_parameter.ods_metadata_input_bucket_name.value }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_ssm_parameter.cloud_watch_log_group.value
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "transfer-classifier/${var.transfer_classifier_image_tag}"
        }
      }
    },
  ])
  cpu                      = 4096
  memory                   = 30720
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-transfer-classifier"
    }
  )
  execution_role_arn = data.aws_ssm_parameter.execution_role_arn.value
  task_role_arn      = aws_iam_role.transfer_classifier.arn
}
