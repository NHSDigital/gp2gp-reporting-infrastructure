resource "aws_sfn_state_machine" "spine_exporter_and_transfer_classifier" {
  name     = "daily-spine-exporter-and-transfer-classifier"
  role_arn = aws_iam_role.spine_exporter_and_transfer_classifier_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Spine Exporter and Transfer Classifier Step Function"
    }
  )
  definition = jsonencode({
    "StartAt" : "SpineExporter",
    "States" : {
      "SpineExporter" : {
        "Type" : "Task",
        "Comment" : "Spine Exporter - responsible for taking fetching raw spine transfer data",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.spine_exporter_task_definition_arn.value,
          "NetworkConfiguration" : {
            "AwsvpcConfiguration" : {
              "Subnets" : [
                data.aws_ssm_parameter.data_pipeline_private_subnet_id.value
              ],
              "SecurityGroups" : [
              data.aws_ssm_parameter.outbound_only_security_group_id.value],
            }
          }
        },
        "Retry" : [{
          "ErrorEquals" : ["States.TaskFailed"],
          "IntervalSeconds" : 10,
          "MaxAttempts" : 2,
          "BackoffRate" : 2.0
        }],
        "Next" : "TransferClassifier1DayCutoff"
      },
      "TransferClassifier1DayCutoff" : {
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
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value" : "1"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "TransferClassifier2DayCutoff"
      },
      "TransferClassifier2DayCutoff" : {
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
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value" : "2"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "TransferClassifier14DayCutoff"
      },
      "TransferClassifier14DayCutoff" : {
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
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "Value" : "14"
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