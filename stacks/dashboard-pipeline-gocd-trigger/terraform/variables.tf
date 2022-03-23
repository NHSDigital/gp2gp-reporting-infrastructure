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

variable "gocd_trigger_lambda_zip" {
  type        = string
  description = "path to zipfile containing lambda code for triggering Dashboard Pipeline GoCD pipeline"
  default     = "lambda/build/dashboard-pipeline-gocd-trigger.zip"
}