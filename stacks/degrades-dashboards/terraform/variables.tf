variable "degrades_dashboards_api_lambda_zip" {
  type        = string
  description = "File path for Degrades API Lambda zip"
  default     = "lambda/build/degrades-api-dashboards.zip"
}

variable "degrades_message_receiver_lambda_zip" {
  type        = string
  description = "File path Degrades Message Receiver Lambda"
  default     = "lambda/build/degrades-message-receiver.zip"
}

variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "degrades_api_lambda_name" {
  type        = string
  description = "Name of Degrades API lambda"
  default     = "degrades_api_dashboards_lambda"
}

variable "degrades_message_receiver_lambda_name" {
  type        = string
  description = "Name of Degrades Message Receiver Lambda"
  default     = "degrades_message_receiver_lambda"
}

variable "registrations_mi_event_bucket" {
  type        = string
  description = "Name of GP2GP messages bucket"
}

variable "degrades_message_table" {
  type        = string
  description = "Name of Degrades Message DynamoDB table"
}