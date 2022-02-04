resource "aws_sfn_state_machine" "reports_generator" {
  name     = "reports-generator"
  role_arn = aws_iam_role.report_generator_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Reports Generator Step Function"
    }
  )
  definition = jsonencode({
    "StartAt" : "GenerateReport",
    "States" : {
      "GenerateReport" : {
        "Type" : "Task",
        "Comment" : "Reports Generator - creates a specific report needed for analysing GP2GP transfers",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.reports_generator_task_definition_arn.value,
          "NetworkConfiguration" : {
            "AwsvpcConfiguration" : {
              "Subnets" : [
                data.aws_ssm_parameter.data_pipeline_private_subnet_id.value
              ],
              "SecurityGroups" : [
                data.aws_ssm_parameter.outbound_only_security_group_id.value],
            }
          },
          "Overrides" : {
            "ContainerOverrides" : [
              {
                "Name" : "reports-generator",
                "Environment" : [
                  {
                    "Name" : "REPORT_NAME",
                    "Value.$" : "$.REPORT_NAME"
                  },
                  {
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value.$" : "$.CONVERSATION_CUTOFF_DAYS"
                  },
                  {
                    "Name" : "NUMBER_OF_DAYS",
                    "Value.$" : "$.NUMBER_OF_DAYS"
                  },
                ],
              }
            ]
          }
        },
        "End" : true
      }
    }
  })
}

data "aws_ssm_parameter" "reports_generator_task_definition_arn" {
  name = var.reports_generator_task_definition_arn_param_name
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