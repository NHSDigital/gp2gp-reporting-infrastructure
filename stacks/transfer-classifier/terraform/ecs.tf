data "aws_ssm_parameter" "transfer_classifier_repository_url" {
  name = var.transfer_classifier_repo_param_name
}

data "aws_ssm_parameter" "spine_messages_input_bucket_name" {
  name = var.spine_messages_input_bucket_param_name
}

data "aws_ssm_parameter" "cloud_watch_log_group" {
  name = var.log_group_param_name
}