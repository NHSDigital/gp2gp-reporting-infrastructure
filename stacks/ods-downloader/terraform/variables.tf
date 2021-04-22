variable "environment" {
  type = string
  description = "Uniquely idenities each deployment, i.e. dev, prod."
}

variable "team" {
  type = string
  default = "Registrations"
  description = "Team owning this resource"
}

variable "repo_name" {
  type = string
  default = "prm-gp2gp-data-pipeline-infra"
  description = "Name of this repository"
}

variable "ods_downloader_repo_param_name" {
  type        = string
  description = "Docker repository of Ods Downloader"
}

variable "ods_downloader_image_tag" {
  type        = string
  description = "Docker image tag of Ods Downloader"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "region" {
  type        = string
  description = "AWS region."
  default     = "eu-west-2"
}