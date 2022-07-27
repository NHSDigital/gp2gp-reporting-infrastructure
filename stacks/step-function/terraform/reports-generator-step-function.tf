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
    "StartAt" : "Determining reporting window",
    "States" : {
      "Determining reporting window" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "And" : [
              {
                "Variable" : "$.START_DATETIME",
                "IsPresent" : true
              },
              {
                "Variable" : "$.END_DATETIME",
                "IsPresent" : true
              }
            ],
            "Next" : "Custom reporting window"
          },
          {
            "Variable" : "$.NUMBER_OF_DAYS",
            "IsPresent" : true
            "Next" : "Daily/weekly reporting window"
          },
          {
            "Variable" : "$.NUMBER_OF_MONTHS",
            "IsPresent" : true
            "Next" : "Monthly reporting window"
          }
        ]
      },
      "Custom reporting window" : {
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
                    "Name" : "START_DATETIME",
                    "Value.$" : "$.START_DATETIME"
                  },
                  {
                    "Name" : "END_DATETIME",
                    "Value.$" : "$.END_DATETIME"
                  },
                  {
                    "Name" : "ALERT_ENABLED",
                    "Value.$" : tostring("$.ALERT_ENABLED")
                  },
                ],
              }
            ]
          }
        },
        "End" : true
      },
      "Daily/weekly reporting window" : {
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
                  {
                    "Name" : "ALERT_ENABLED",
                    "Value.$" : tostring("$.ALERT_ENABLED")
                  },
                ],
              }
            ]
          }
        },
        "End" : true
      },
      "Monthly reporting window" : {
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
                    "Name" : "NUMBER_OF_MONTHS",
                    "Value.$" : "$.NUMBER_OF_MONTHS"
                  },
                  {
                    "Name" : "ALERT_ENABLED",
                    "Value.$" : tostring("$.ALERT_ENABLED")
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