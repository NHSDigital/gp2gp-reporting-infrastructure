resource "aws_sfn_state_machine" "transfer_classifier" {
  name     = "transfer-classifier"
  role_arn = aws_iam_role.transfer_classifier_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Transfer Classifier Step Function"
    }
  )
  definition = jsonencode({
    "StartAt" : "Has Start and End Datetime",
    "States" : {
      "Has Start and End Datetime" : {
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
            "Next" : "TransferClassifier (with start/end datetime)"
          }
        ],
        "Default" : "TransferClassifier (without start/end datetime)"
      },
      "TransferClassifier (with start/end datetime)" : {
        "Type" : "Task",
        "Comment" : "Transfer Classifier - responsible for taking raw spine transfer data and organisation meta data and allocating transfers a status",
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
      "TransferClassifier (without start/end datetime)" : {
        "Type" : "Task",
        "Comment" : "Transfer Classifier - responsible for taking raw spine transfer data and organisation meta data and allocating transfers a status",
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
      }
    }
  })
}
