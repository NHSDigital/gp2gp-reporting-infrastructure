resource "aws_iam_role" "ecs_events" {
  name               = "${var.environment}-spine-exporter-ecs-events"
  description        = "Role for spine exporter Cloudwatch Event scheduler"
  assume_role_policy = data.aws_iam_policy_document.ecs_events_assume.json
  managed_policy_arns = [
    aws_iam_policy.ecs_events_run_task.arn,
  ]
}

data "aws_iam_policy_document" "ecs_events_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_events_run_task" {
  name   = "${var.environment}-spine-exporter-ecs-events-run-task"
  policy = data.aws_iam_policy_document.run_task.json
}

data "aws_iam_policy_document" "run_task" {
  statement {
    sid = "PassIamRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      data.aws_ssm_parameter.execution_role_arn.value,
      aws_iam_role.spine_exporter.arn
    ]
  }

  statement {
    sid = "RunSpineExporterEcsTask"
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      aws_ecs_task_definition.spine_exporter.arn
    ]
  }
}

resource "aws_cloudwatch_event_rule" "ecs_event_rule" {
  name                = "run-spine-exporter-2am-every-morning"
  description         = "Cloudwatch Event Rule that runs Spine Exporter ECS task 2am every morning"
  schedule_expression = "cron(0 2 * * ? *)"

  tags = merge(
    local.common_tags,
    {
      Name = "Cloudwatch Event Rule"
    }
  )
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${var.environment}-spine-exporter"
  arn       = data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value
  rule      = aws_cloudwatch_event_rule.ecs_event_rule.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets         = [data.aws_ssm_parameter.data_pipeline_private_subnet_id.value]
      security_groups = [data.aws_ssm_parameter.outbound_only_security_group_id.value]
    }
    task_definition_arn = aws_ecs_task_definition.spine_exporter.arn
    tags = merge(
      local.common_tags,
      {
        Name = "Cloudwatch Event Target"
      }
    )
  }
}

data "aws_ssm_parameter" "data_pipeline_ecs_cluster_arn" {
  name = var.data_pipeline_ecs_cluster_arn_param_name
}

data "aws_ssm_parameter" "data_pipeline_private_subnet_id" {
  name = var.data_pipeline_private_subnet_id_param_name
}

data "aws_ssm_parameter" "outbound_only_security_group_id" {
  name = var.data_pipeline_outbound_only_security_group_id_param_name
}
