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

variable "transfer_classifier_repo_param_name" {
  type        = string
  description = "Docker repository of the transfer classifier"
}

variable "spine_messages_input_bucket_param_name" {
  type        = string
  description = "SSM parameter containing raw transfer input bucket name"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "ods_metadata_input_bucket_param_name" {
  type        = string
  description = "SSM parameter containing organisation metadata bucket name"
}

variable "transfer_classifier_image_tag" {
  type        = string
  description = "Docker image tag of the transfer classifier"
}