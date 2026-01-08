data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}

data "aws_route53_zone" "gp_registrations" {
  name         = var.hosted_zone_name
  private_zone = false
}

locals {
  ses_receipt_rule_asid_lookup_name = "store-asid-lookup-in-s3-${var.environment}"
}