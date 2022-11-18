variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "s3_terraform_state_bucket_name" {
  type        = string
  description = "Bucket name for terraform state"
}
