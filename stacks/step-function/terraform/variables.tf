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
  default     = "gp2gp-reporting-infrastructure"
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

variable "gp2gp_dashboard_iam_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing gp2gp dashboard iam role arn"
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

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "gp2gp_dashboard_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing GP2GP Dashboard Task Definition ARN"
}

variable "validate_metrics_lambda_arn_param_name" {
  type        = string
  description = "SSM parameter containing Validate Metrics Lambda ARN"
}

variable "gp2gp_dashboard_alert_lambda_arn_param_name" {
  type        = string
  description = "SSM parameter containing the gp2gp dashboard alert lambda ARN"
}