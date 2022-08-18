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

variable "email_report_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for emails"
  default     = "lambda/build/email-report.zip"
}

variable "log_alerts_technical_failures_above_threshold_rate_param_name" {
  type        = string
  description = "SSM parameter containing the technical failure rate threshold percentage"
}

variable "email_report_sender_email_param_name" {
  type        = string
  description = "SSM parameter containing the sender email address for emailing reports"
}

variable "email_report_recipient_email_param_name" {
  type        = string
  description = "SSM parameter containing the recipient email address for emailing reports"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "reports_generator_bucket_param_name" {
  type        = string
  description = "Reports generator output bucket name"
}