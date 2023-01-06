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
    "StartAt" : "Trigger Dashboard Pipeline GoCD Trigger?",
    "States" : {
      "Trigger Dashboard Pipeline GoCD Trigger?" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.SKIP_DASHBOARD_PIPELINE_GOCD_TRIGGER",
            "BooleanEquals" : true,
            "Next" : "MetricsCalculator"
          }
        ],
        "Default" : "MetricsCalculatorWithTrigger"
      },
      "MetricsCalculatorWithTrigger" : {
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
        "Next" : "DashboardPipelineGocdTrigger"
      },
      "DashboardPipelineGocdTrigger" : {
        "Type" : "Task",
        "Comment" : "Dashboard Pipeline Gocd Trigger - triggers gocd from the common account to build the latest dashboard ui",
        "Resource" : data.aws_ssm_parameter.gocd_trigger_lambda_arn.value,
        "ResultPath" : null,
        "End" : true
      },
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
        "End" : true
      },
    }
  })
}

data "aws_ssm_parameter" "metrics_calculator_task_definition_arn" {
  name = var.metrics_calculator_task_definition_arn_param_name
}

data "aws_ssm_parameter" "gocd_trigger_lambda_arn" {
  name = var.gocd_trigger_lambda_arn_param_name
}
