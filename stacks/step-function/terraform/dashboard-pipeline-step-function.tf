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
    "StartAt" : "Skip MetricsCalculator?",
    "Comment": "Add option to skip generating the metrics - useful for code only changes that don't require the data to be updated"
    "States" : {
      "Skip MetricsCalculator?" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.SKIP_METRICS",
            "BooleanEquals" : true,
            "Next" : "GP2GP Dashboard Build And Deploy"
          }
        ],
        "Default" : "MetricsCalculator"
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
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "Next": "GP2GP Dashboard Alert - FAILED",
            "ResultPath": "$.metricsFailed"
          }
        ],
        "Next" : "ValidateMetrics"
      },
      "ValidateMetrics" : {
        "Comment" : "Validate Metrics - responsible for reading practice and national metrics and validating them",
        "Type": "Task",
        "Resource" : data.aws_ssm_parameter.validate_metrics_lambda_arn.value,
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "Next": "GP2GP Dashboard Alert - FAILED",
            "ResultPath": "$.validationError"
          }
        ],
        "Next" : "GP2GP Dashboard Build And Deploy"
      },
      "GP2GP Dashboard Build And Deploy" : {
        "Type" : "Task",
        "Comment" : "GP2GP Dashboard Build And Deploy Fronted",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : "$.dashboardBuildAndDeploy",
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
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "Next": "GP2GP Dashboard Alert - FAILED",
            "ResultPath": "$.dashboardError"
          }
        ],
        "Next" : "GP2GP Dashboard Alert - SUCCESS"
      },
      "GP2GP Dashboard Alert - SUCCESS" : {
        "Comment" : "GP2GP Dashboard Alert - runs a lambda to send a success alert to teams",
        "Type": "Task",
        "Resource" : data.aws_ssm_parameter.gp2gp_dashboard_alert_lambda_arn.value,
        "End" : true
      },
      "GP2GP Dashboard Alert - FAILED" : {
        "Comment" : "GP2GP Dashboard Alert - runs a lambda to send a success alert to teams",
        "Type": "Task",
        "Resource" : data.aws_ssm_parameter.gp2gp_dashboard_alert_lambda_arn.value,
        "Next" : "Fail"
      },
      "Fail": {
        "Type": "Fail"
      }
    }
  })
}

data "aws_ssm_parameter" "metrics_calculator_task_definition_arn" {
  name = var.metrics_calculator_task_definition_arn_param_name
}

data "aws_ssm_parameter" "gp2gp_dashboard_task_definition_arn" {
  name = var.gp2gp_dashboard_task_definition_arn_param_name
}

data "aws_ssm_parameter" "validate_metrics_lambda_arn" {
  name = var.validate_metrics_lambda_arn_param_name
}

data "aws_ssm_parameter" "gp2gp_dashboard_alert_lambda_arn" {
  name = var.gp2gp_dashboard_alert_lambda_arn_param_name
}