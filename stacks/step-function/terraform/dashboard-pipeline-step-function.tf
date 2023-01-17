resource "aws_sfn_state_machine" "dashboard_pipeline" {
  name     = "dashboard-pipeline"
  role_arn = aws_iam_role.dashboard_pipeline_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dashboard-pipeline-step-function"
      ApplicationRole = "AwsSfnStateMachine"
    }
  )
  definition = jsonencode({
    "StartAt" : "MetricsCalculator",
    "States" : {
      "MetricsCalculator" : {
        "Type" : "Task",
        "Comment" : "Metrics calculator - responsible for taking transfer data and organisation meta data and calculating metrics for the platform",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.metrics_calculator_task_definition_arn.value,
          "NetworkConfiguration" : {
            "AwsvpcConfiguration" : {
              "Subnets" : [
                data.aws_ssm_parameter.data_pipeline_private_subnet_id.value
              ],
              "SecurityGroups" : [
                data.aws_ssm_parameter.outbound_only_security_group_id.value],
            }
          },
        },
        "Next" : "GP2GP Dashboard Build And Deploy"
      },
      "GP2GP Dashboard Build And Deploy" : {
        "Type" : "Task",
        "Comment" : "GP2GP Dashboard Build And Deploy Fronted",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.gp2gp_dashboard_task_definition_arn.value
          "NetworkConfiguration" : {
            "AwsvpcConfiguration" : {
              "Subnets" : [
                data.aws_ssm_parameter.data_pipeline_private_subnet_id.value
              ],
              "SecurityGroups" : [
              data.aws_ssm_parameter.outbound_only_security_group_id.value],
            }
          },
        },
        "End" : true
      },
    }
  })
}

data "aws_ssm_parameter" "metrics_calculator_task_definition_arn" {
  name = var.metrics_calculator_task_definition_arn_param_name
}

data "aws_ssm_parameter" "gp2gp_dashboard_task_definition_arn" {
  name = var.gp2gp_dashboard_task_definition_arn_param_name
}
