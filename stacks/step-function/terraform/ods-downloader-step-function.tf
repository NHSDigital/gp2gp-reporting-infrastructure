resource "aws_sfn_state_machine" "ods_downloader" {
  name     = "ods-downloader-pipeline"
  role_arn = aws_iam_role.ods_downloader_step_function.arn
  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-ods-downloader-pipeline-step-function"
      ApplicationRole = "AwsSfnStateMachine"
    }
  )
  definition = jsonencode({
    "StartAt" : "ODSDownloader",
    "States" : {
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
        "End" : true
      },
    }
  })
}

data "aws_ssm_parameter" "ods_downloader_task_definition_arn" {
  name = var.ods_downloader_task_definition_arn_param_name
}

output "ods_downloader_arn {

  value = aws_sfn_state_machine.ods_downloader.arn

}