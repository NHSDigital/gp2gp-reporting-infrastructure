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

variable "vpc_cidr" {
  type        = string
  description = "CIDR block to assign VPC"
}

variable "private_cidr_offset" {
  type        = number
  description = "CIDR address offset to begin creating private subnets at"
  default     = 100
}

variable "gocd_vpc_id_param_name" {
  type        = string
  description = "SSM parameter containing GoCD VPC ID (from separate account)"
}
