variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "s3_terraform_state_bucket_name" {
  type        = string
  description = "Bucket name for terraform state"
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
