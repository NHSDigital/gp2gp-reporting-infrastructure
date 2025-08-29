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
  default     = "gp2gp-reporting-infrastructure"
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
