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

variable "region" {
  type        = string
  description = "AWS region."
  default     = "eu-west-2"
}

variable "gocd_trigger_lambda_zip" {
  type        = string
  description = "path to zipfile containing lambda code for triggering Dashboard Pipeline GoCD pipeline"
  default     = "lambda/build/dashboard-pipeline-gocd-trigger.zip"
}

variable "gocd_trigger_api_url_ssm_param_name" {
  type        = string
  description = "Name of SSM parameter containing GoCD URL that will trigger the Dashboard GoCD pipeline"
}

variable "gocd_trigger_api_token_ssm_param_name" {
  type        = string
  description = "Name of SSM parameter containing GoCD API token that will be used to call Dashboard GoCD pipeline URL"
}

variable "data_pipeline_private_subnet_id_param_name" {
  type        = string
  description = "SSM parameter containing Data Pipeline Private Subnet ID"
}

variable "data_pipeline_outbound_only_security_group_id_param_name" {
  type        = string
  description = "SSM parameter containing Data Pipeline outbound only Security Group ID"
}