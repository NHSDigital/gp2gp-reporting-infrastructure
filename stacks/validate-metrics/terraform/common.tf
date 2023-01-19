data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

#data "aws_ssm_parameter" "cloud_watch_log_group" {
#  name = var.log_group_param_name
#}