resource "aws_ecs_cluster" "data_pipeline_cluster" {
  name = "${var.environment}-gp2gp-data-pipeline"
  tags = local.common_tags
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "data_pipeline" {
  name = "/ecs/${var.environment}-data-pipeline"
  tags = merge(
  local.common_tags,
  {
    Name = "${var.environment}-data-pipeline"
  }
  )
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.environment}-gp2gp-data-pipeline-ecs-execution"
  description        = "ECS execution role for data-pipeline tasks"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution.arn
}

resource "aws_iam_policy" "ecs_execution" {
  name   = "${var.environment}-ecs-execution"
  policy = data.aws_iam_policy_document.ecs_execution.json
}

data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid = "GetEcrAuthToken"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "DownloadEcrImage"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      data.aws_ecr_repository.ods_downloader.arn
    ]
  }

  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.data_pipeline.arn}:*"
    ]
  }
}

data "aws_ecr_repository" "ods_downloader" {
  name = data.aws_ssm_parameter.ods_downloader.value
}

data "aws_ssm_parameter" "ods_downloader" {
  name = var.ods_downloader_repo_param_name
}