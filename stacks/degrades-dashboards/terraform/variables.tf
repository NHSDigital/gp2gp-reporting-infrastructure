variable "degrades_dashboards_lambda_zip" {
  type        = string
  description = "File path for Degrades Lambda zip"
  default     = "lambda/build/degrades-dashboards.zip"
}

variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "degrades_lambda_name" {
  default = "degrades_dashboards_lambda"
}

variable "registrations_mi_event_bucket" {
  description = "Name of terraform state bucket"
}