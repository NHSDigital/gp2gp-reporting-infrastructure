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

variable "validate_metrics_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for metrics validation"
  default     = "lambda/build/validate-metrics.zip"
}

variable "validate_metrics_lambda_name" {
  default = "validate-metrics-lambda"
}

variable "s3_practice_metrics_filepath_param_name" {
  type        = string
  description = "SSM parameter containing the s3 practice metrics filepath"
}

variable "s3_national_metrics_filepath_param_name" {
  type        = string
  description = "SSM parameter containing the s3 national metrics filepath"
}


variable "metrics_calculator_bucket_param_name" {
  type        = string
  description = "SSM parameter containing the metrics calculator s3 bucket name"
}

variable "s3_metrics_version" {
  type        = string
  description = "Latest version of s3 metrics"
  default     = "v12"
}