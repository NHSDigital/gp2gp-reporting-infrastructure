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
  name                = "run-spine-exported-every-10-minutes"
  description         = "Cloudwatch Event Rule that runs Spine Exporter ECS task every 10 minutes"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${var.environment}-spine-exporter"
  arn       = data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value
  rule      = aws_cloudwatch_event_rule.ecs_event_rule.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.spine_exporter.arn
  }
}

data "aws_ssm_parameter" "data_pipeline_ecs_cluster_arn" {
  name = var.data_pipeline_ecs_cluster_arn_param_name
}
