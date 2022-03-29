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

variable "metrics_calculator_repo_param_name" {
  type        = string
  description = "Docker repository of the metrics calculator"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "metrics_calculator_image_tag" {
  type        = string
  description = "Docker image tag of the metrics calculator"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "transfers_data_bucket_param_name" {
  type        = string
  description = "SSM parameter containing transfer data bucket name"
}

variable "transfer_data_bucket_read_access_param_name" {
  type        = string
  description = "SSM parameter containing transfer data bucket read access IAM policy ARN"
}

variable "ods_metadata_bucket_param_name" {
  type        = string
  description = "SSM parameter containing ODS Downloader output bucket (ODS metadata) bucket name"
}

variable "national_metrics_s3_path_param_name" {
  type        = string
  description = "SSM parameter containing the national metrics s3 uri"
}

variable "practice_metrics_s3_path_param_name" {
  type        = string
  description = "SSM parameter containing the national metrics s3 uri"
}

variable "ods_metadata_bucket_read_access_arn" {
  type        = string
  description = "SSM parameter containing ODS Downloader output bucket (ODS metadata) read access IAM policy ARN"
}