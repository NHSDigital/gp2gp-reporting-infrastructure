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

variable "email_report_lambda_name" {
  default = "email-report-lambda"
}

variable "email_report_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for emailing reports"
  default     = "lambda/build/email-report.zip"
}

variable "store_asid_lookup_lambda_name" {
  type    = string
  default = "store_asid_lookup_lambda"
}

variable "store_asid_lookup_lambda_zip" {
  type        = string
  description = "Path to zipfile containing code for asid lookup Lambda"
  default     = "lambda/build/store-asid-lookup.zip"
}

variable "log_alerts_technical_failures_above_threshold_rate_param_name" {
  type        = string
  description = "SSM parameter containing the technical failure rate threshold percentage"
}

variable "email_report_sender_email_param_name" {
  type        = string
  description = "SSM parameter containing the sender email address for emailing reports"
}

variable "email_report_sender_email_key_param_name" {
  type        = string
  description = "SSM parameter containing the sender email key for SMTP auth"
}

variable "email_report_recipient_email_param_name" {
  type        = string
  description = "SSM parameter containing the recipient email address for emailing reports"
}

variable "email_report_recipient_internal_email_param_name" {
  type        = string
  description = "SSM parameter containing the recipient internal email address for emailing reports"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "reports_generator_bucket_param_name" {
  type        = string
  description = "Reports generator output bucket name"
}

variable "cloudwatch_dashboard_url" {
  type        = string
  description = "URL of the cloudwatch dashboard pipeline overview"
}

variable "log_alerts_technical_failures_above_threshold_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for log alerts"
  default     = "lambda/build/log-alerts-technical-failures-above-threshold.zip"
}

variable "log_alerts_pipeline_error_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for log alerts"
  default     = "lambda/build/log-alerts-pipeline-error.zip"
}

variable "gp2gp_dashboard_alert_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for log alerts"
  default     = "lambda/build/gp2gp-dashboard-alert.zip"
}

variable "log_alerts_technical_failures_webhook_url_param_name" {
  type        = string
  description = "SSM parameter containing the webhook url to send notifications to"
}

variable "log_alerts_technical_failures_above_threshold_webhook_url_param_name" {
  type        = string
  description = "SSM parameter containing the webhook url to send failure threshold succeeded notifications to"
}

variable "log_alerts_general_webhook_url_param_name" {
  type        = string
  description = "SSM parameter containing the general webhook url channel to send failure threshold succeeded notifications to"
}

variable "gp2gp_dashboard_national_statistics_url" {
  type        = string
  description = "URL for the gp2gp dashboard nationalist statistics"
}

variable "hosted_zone_name" {
  type        = string
  description = "Route53 hosted zone name"
}

variable "asid_lookup_inbox_prefix_param_name" {
  type        = string
  description = "SSM parameter containing the gp2gp inbox address prefix for asid lookup"
}

variable "validate_metrics" {
  description = "Placeholder for shared lambda path"
  type        = string
  default     = ""
}
