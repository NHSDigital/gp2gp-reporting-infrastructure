resource "aws_sfn_state_machine" "transfer_classifier" {
  name     = "transfer-classifier-manual"
  role_arn = aws_iam_role.transfer_classifier_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Transfer Classifier Step Function Manual Run"
    }
  )
  definition = jsonencode({
    "StartAt" : "Classify Spine or MiEvents?",
    "States" : {
      "Classify Spine or MiEvents?" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.CLASSIFY_MI_EVENTS",
            "BooleanEquals" : true,
            "Next" : "TransferClassifierMiEvents"
          }
        ],
        "Default" : "TransferClassifierSpine"
      },
      "TransferClassifierMiEvents" : {
        "Type" : "Task",
        "Comment" : "Transfer Classifier Mi Events - responsible for taking mi events and organisation meta data and allocating transfers a status",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.transfer_classifier_task_definition_arn.value,
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
                "Name" : "transfer-classifier",
                "Environment" : [
                  {
                    "Name" : "START_DATETIME",
                    "Value.$" : "$.START_DATETIME"
                  },
                  {
                    "Name" : "END_DATETIME",
                    "Value.$" : "$.END_DATETIME"
                  },
                  {
                    "Name" : "OUTPUT_TRANSFER_DATA_BUCKET",
                    "Value.$" : "$.OUTPUT_TRANSFER_DATA_BUCKET"
                  },
                  {
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value.$" : "$.CONVERSATION_CUTOFF_DAYS"
                  },
                  {
                    "Name" : "CLASSIFY_MI_EVENTS",
                    "Value.$" : "True"
                  }
                ],
              }
            ]
          }
        },
        "End" : true
      },
      "TransferClassifierSpine" : {
        "Type" : "Task",
        "Comment" : "Transfer Classifier Spine - responsible for taking raw spine transfer data and organisation meta data and allocating transfers a status",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.transfer_classifier_task_definition_arn.value,
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
                "Name" : "transfer-classifier",
                "Environment" : [
                  {
                    "Name" : "START_DATETIME",
                    "Value.$" : "$.START_DATETIME"
                  },
                  {
                    "Name" : "END_DATETIME",
                    "Value.$" : "$.END_DATETIME"
                  },
                  {
                    "Name" : "OUTPUT_TRANSFER_DATA_BUCKET",
                    "Value.$" : "$.OUTPUT_TRANSFER_DATA_BUCKET"
                  },
                  {
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value.$" : "$.CONVERSATION_CUTOFF_DAYS"
                  }
                ],
              }
            ]
          }
        },
        "End" : true
      },
    }
  })
}
