variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
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

variable "spine_exporter_repo_param_name" {
  type        = string
  description = "Docker repository of Spine exporter"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "spine_exporter_image_tag" {
  type        = string
  description = "Docker image tag of the spine exporter"
}

variable "splunk_url_param_name" {
  type        = string
  description = "Splunk URL param name"
}

variable "splunk_api_token_param_name" {
  type        = string
  description = "Splunk API token param name"
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