resource "aws_sfn_state_machine" "spine_exporter_and_transfer_classifier" {
  name     = "automated-daily-spine-exporter-and-transfer-classifier"
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
        "Next" : "TransferClassifier"
      },
      "TransferClassifier" : {
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