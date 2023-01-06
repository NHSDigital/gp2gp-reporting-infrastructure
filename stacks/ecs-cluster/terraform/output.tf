resource "aws_ssm_parameter" "cloudwatch_log_group_name" {
  name  = "/registrations/${var.environment}/data-pipeline/cloudwatch-log-group-name"
  type  = "String"
  value = aws_cloudwatch_log_group.data_pipeline.name
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dashboard-pipeline-gocd-cloudwatch-log-group-name"
      ApplicationRole = "AwsSsmParameter"
    }
  )

}

resource "aws_ssm_parameter" "execution_role_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ecs-execution-role-arn"
  type  = "String"
  value = aws_iam_role.ecs_execution.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dashboard-pipeline-gocd-execution-role-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

resource "aws_ssm_parameter" "ecs_cluster_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/ecs-cluster/ecs-cluster-arn"
  type  = "String"
  value = aws_ecs_cluster.data_pipeline_cluster.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dashboard-pipeline-gocd-data-pipeline-ecs-cluster-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )

}
