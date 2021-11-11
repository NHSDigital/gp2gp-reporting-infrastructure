resource "aws_iam_role" "spine_exporter" {
  name               = "${var.environment}-registrations-spine-exporter"
  description        = "Role for spine exporter ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
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