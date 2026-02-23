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
  default     = "gp2gp-reporting-infrastructure"
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

variable "splunk_index_param_name" {
  type        = string
  description = "Splunk index param name"
}

variable "splunk_api_token_param_name" {
  type        = string
  description = "Splunk API token param name"
}
