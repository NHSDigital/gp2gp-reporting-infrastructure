variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
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

variable "reports_generator_repo_param_name" {
  type        = string
  description = "Docker repository of the reports generator"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "reports_generator_image_tag" {
  type        = string
  description = "Docker image tag of the reports generator"
}

variable "log_group_param_name" {
type        = string
description = "Cloudwatch log group for data pipeline"
}

variable "transfers_input_bucket_param_name" {
  type        = string
  description = "SSM parameter containing transfer input bucket name"
}

variable "transfer_input_bucket_read_access_param_name" {
  type        = string
  description = "SSM parameter containing transfer input bucket read access IAM policy ARN"
}

variable "notebook_data_bucket_name" {
  type        = string
  description = "Location of the bucket name for notebook data (that the reports generator can output to)"
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