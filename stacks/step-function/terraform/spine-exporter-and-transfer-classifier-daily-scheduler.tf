

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