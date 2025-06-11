variable "degrades_lambda_zip_file" {
  type        = string
  description = "File path for Degrades Lambda zip"
  value       = "lambda/build/degrades_lambda.zip"
}

variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "degrades_lambda_name" {
  default = "calculate_degrades_lambda"
}
