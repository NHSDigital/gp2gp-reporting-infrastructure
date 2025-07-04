variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "store_asid_lookup_lambda_name" {
  type        = string
  description = "Name of Store Asid Lookup Lambda"
  default     = "store_asid_lookup_lambda"
}

variable "store_asid_lookup_lambda_zip" {
  type        = string
  description = "Store Asid Lookup Lambda"
  default     = "lambda/build/store-asid-lookup.zip"
}

variable "gp2gp_inbox_storage_bucket_arn" {
  description = "ARN of the GP2GP inbox storage bucket"
  type        = string
}

variable "gp2gp_asid_lookup_bucket_arn" {
  description = "ARN of the GP2GP asid lookup storage bucket"
  type        = string
}
