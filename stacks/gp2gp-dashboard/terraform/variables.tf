variable "environment" {
  type        = string
  description = "Uniquely identifies each deployment, i.e. dev, prod."
}

variable "team" {
  type        = string
  default     = "Registrations"
  description = "Team owning this resource"
}

variable "repo_name" {
  type        = string
  default     = "prm-gp2gp-dashboard-infra"
  description = "Name of this repository"
}

variable "region" {
  type        = string
  description = "AWS region."
  default     = "eu-west-2"
}

variable "s3_dashboard_bucket_name" {
  type = string
}

variable "alternate_domain_name" {
  type        = string
  description = "Alternate Domain Names (CNAME) for CloudFront distribution"
}

variable "gp2gp_dashboard_repo_param_name" {
  type        = string
  description = "Docker repository of the reports generator"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for data pipeline"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "metrics_input_bucket_param_name" {
  type        = string
  description = "SSM parameter containing metrics input bucket name"
}

variable "gp2gp_dashboard_image_tag" {
  type        = string
  description = "Docker image tag of the reports generator"
}

variable "zone_name" {
  type = string
  description = "Route 53 zone name for GP2GP Dashboard"
}


