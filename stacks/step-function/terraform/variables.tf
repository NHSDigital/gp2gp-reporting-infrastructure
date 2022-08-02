variable "environment" {
  type        = string
  description = "Uniquely identifies each deployment, i.e. dev, prod."
}

variable "team" {
  type        = string
  default     = "Registrations"
  description = "Team owning this resource"
}

variable "repo_name" {
  type        = string
  default     = "prm-gp2gp-data-pipeline-infra"
  description = "Name of this repository"
}

variable "data_pipeline_ecs_cluster_arn_param_name" {
  type        = string
  description = "SSM parameter containing Data Pipeline ECS Cluster ARN"
}

variable "data_pipeline_private_subnet_id_param_name" {
  type        = string
  description = "SSM parameter containing Data Pipeline Private Subnet ID"
}

variable "data_pipeline_outbound_only_security_group_id_param_name" {
  type        = string
  description = "SSM parameter containing Data Pipeline outbound only Security Group ID"
}

variable "data_pipeline_execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "ods_downloader_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ODS downloader iam role arn"
}

variable "ods_downloader_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing ODS downloader Task Definition ARN"
}

variable "metrics_calculator_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing metrics calculator iam role arn"
}

variable "metrics_calculator_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing metrics calculator Task Definition ARN"
}

variable "transfer_classifier_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing transfer classifier iam role arn"
}

variable "transfer_classifier_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing transfer classifier Task Definition ARN"
}

variable "spine_exporter_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing spine exporter Task Definition ARN"
}

variable "spine_exporter_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing spine exporter iam role arn"
}

variable "reports_generator_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing reports generator iam role arn"
}

variable "reports_generator_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing reports generator Task Definition ARN"
}

variable "transfer_data_bucket_name" {
  type        = string
  description = "Location of the bucket name for transfer data (that the transfer classifier outputs to)"
}

variable "gocd_trigger_lambda_arn_param_name" {
  type        = string
  description = "SSM parameter containing gocd trigger lambda arn"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "log_alerts_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for log alerts"
  default     = "lambda/build/log-alerts.zip"
}

variable "log_alerts_webhook_url_ssm_path" {
  type        = string
  description = "Path containing the webhook url to send notifications to"
}

variable "log_alerts_exceeded_threshold_webhook_url_ssm_path" {
  type        = string
  description = "Path containing the webhook url to send failure threshold succeeded notifications to"
}

variable "log_alerts_exceeded_threshold_webhook_url_channel_two_ssm_path" {
  type        = string
  description = "Path containing the webhook url second channel to send failure threshold succeeded notifications to"
}

variable "log_alerts_technical_failure_rate_threshold_ssm_path" {
  type        = string
  description = "Path containing the technical failure rate threshold percentage"
}
