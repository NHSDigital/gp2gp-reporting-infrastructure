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
    "StartAt" : "TransferClassifier",
    "States" : {
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
                    "Name" : "DATE_ANCHOR",
                    "Value.$" : "$.time"
                  },
                  {
                    "Name" : "CONVERSATION_CUTOFF_DAYS",
                    "StaticValue" : "14"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "ReportsGenerator"
      },
      "ReportsGenerator" : {
        "Type" : "Task",
        "Comment" : "Reports Generator - responsible for generating various reports needed for reporting on GP2GP",
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
                    "Name" : "DATE_ANCHOR",
                    "Value.$" : "$.time"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "ODSDownloader"
      },
      "ODSDownloader" : {
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
                    "Name" : "DATE_ANCHOR",
                    "Value.$" : "$.time"
                  }
                ],
              }
            ]
          }
        },
        "Next" : "MetricsCalculator"
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
          "Overrides" : {
            "ContainerOverrides" : [
              {
                "Name" : "metrics-calculator",
                "Environment" : [
                  {
                    "Name" : "DATE_ANCHOR",
                    "Value.$" : "$.time"
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

resource "aws_sfn_state_machine" "transfer_classifer" {
  name     = "transfer-classifer"
  role_arn = aws_iam_role.data_pipeline_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name = "Transfer Classifier Step Function"
    }
  )
  definition = jsonencode({
    "StartAt" : "TransferClassifier",
    "States" : {
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
                    "Name" : "START_DATETIME",
                    "Value.$" : "$.START_DATETIME"
                  },
                  {
                    "Name" : "END_DATETIME",
                    "Value.$" : "$.END_DATETIME"
                  },
                  {
                    "Name" : "INPUT_SPINE_DATA_BUCKET",
                    "Value.$" : "$.INPUT_SPINE_DATA_BUCKET"
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
      }
    }
  })
}

data "aws_ssm_parameter" "ods_downloader_task_definition_arn" {
  name = var.ods_downloader_task_definition_arn_param_name
}

data "aws_ssm_parameter" "transfer_classifier_task_definition_arn" {
  name = var.transfer_classifier_task_definition_arn_param_name
}

data "aws_ssm_parameter" "metrics_calculator_task_definition_arn" {
  name = var.metrics_calculator_task_definition_arn_param_name
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
