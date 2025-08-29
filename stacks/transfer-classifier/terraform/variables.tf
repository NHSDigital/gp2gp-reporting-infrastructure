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

variable "transfer_classifier_repo_param_name" {
  type        = string
  description = "Docker repository of the transfer classifier"
}

variable "spine_messages_bucket_param_name" {
  type        = string
  description = "SSM parameter containing raw spine messages (output from Spine Exporter) bucket name"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "transfer_classifier_image_tag" {
  type        = string
  description = "Docker image tag of the transfer classifier"
}

variable "notebook_data_bucket_name" {
  type        = string
  description = "Location of the bucket name for notebook data (that the transfer classifier can output to)"
}

variable "ods_metadata_bucket_param_name" {
  type        = string
  description = "SSM parameter containing ODS Downloader output bucket (ODS metadata) bucket name"
}

variable "ods_metadata_bucket_read_access_arn" {
  type        = string
  description = "SSM parameter containing ODS Downloader output bucket (ODS metadata) read access IAM policy ARN"
}
