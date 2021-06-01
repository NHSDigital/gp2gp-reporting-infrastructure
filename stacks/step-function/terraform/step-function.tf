resource "aws_sfn_state_machine" "data_pipeline" {
  name     = "data-pipeline"
  role_arn = aws_iam_role.data_pipeline_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Data Pipeline Step Function"
    }
  )
  definition = jsonencode({
    "StartAt" : "odsdownloader",
    "States" : {
      "odsdownloader" : {
        "Type" : "Task",
        "Comment" : "ODS Downloader - responsible for fetching ODS codes and names of all active GP practices and saving it to JSON file.",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.ods_downloader_task_definition_arn.value,
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
                "Name" : "ods-downloader",
                "Environment" : [
                  {
                    "Name" : "MAPPING_BUCKET",
                    "Value.$" : "$.mappingBucket"
                  },
                  {
                    "Name" : "OUTPUT_BUCKET",
                    "Value.$" : "$.outputBucket"
                  },
                  {
                    "Name" : "YEAR",
                    "Value.$" : "$.year"
                  },
                  {
                    "Name" : "MONTH",
                    "Value.$" : "$.month"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "PlatformMetricsCalculator"
      },
      "PlatformMetricsCalculator" : {
        "Type" : "Task",
        "Comment" : "Platform metrics calculator - responsible for taking raw spine transfer data and organisation meta data and allocating transfers a status",
        "Resource" : "arn:aws:states:::ecs:runTask.sync",
        "ResultPath" : null,
        "Parameters" : {
          "LaunchType" : "FARGATE",
          "Cluster" : data.aws_ssm_parameter.data_pipeline_ecs_cluster_arn.value,
          "TaskDefinition" : data.aws_ssm_parameter.platform_metrics_calculator_task_definition_arn.value,
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
                "Name" : "platform-metrics-calculator",
                "Environment" : [
                  {
                    "Name" : "OUTPUT_TRANSFER_DATA_BUCKET",
                    "Value.$" : "$.outputTransferDataBucket"
                  },                  {
                    "Name" : "INPUT_TRANSFER_DATA_BUCKET",
                    "Value.$" : "$.inputTransferDataBucket"
                  },
                  {
                    "Name" : "ORGANISATION_LIST_BUCKET",
                    "Value.$" : "$.organisationListBucket"
                  },
                  {
                    "Name" : "YEAR",
                    "Value.$" : "$.year"
                  },
                  {
                    "Name" : "MONTH",
                    "Value.$" : "$.month"
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

data "aws_ssm_parameter" "ods_downloader_task_definition_arn" {
  name = var.ods_downloader_task_definition_arn_param_name
}

data "aws_ssm_parameter" "platform_metrics_calculator_task_definition_arn" {
  name = var.platform_metrics_calculator_task_definition_arn_param_name
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
