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

variable "transfer_classifier_repo_param_name" {
  type        = string
  description = "Docker repository of the transfer classifier"
}

variable "spine_messages_input_bucket_param_name" {
  type        = string
  description = "SSM parameter containing raw transfer input bucket name"
}