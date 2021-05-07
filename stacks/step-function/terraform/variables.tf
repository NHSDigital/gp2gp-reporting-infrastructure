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

variable "region" {
  type        = string
  description = "AWS region."
  default     = "eu-west-2"
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
  description = "SSM parameter containing ods downloader iam role arn"
}

variable "ods_downloader_task_definition_arn_param_name" {
  type        = string
  description = "SSM parameter containing ODS downloader Task Definition ARN"
}