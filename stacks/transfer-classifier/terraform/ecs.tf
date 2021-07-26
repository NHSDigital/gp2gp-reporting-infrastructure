data "aws_ssm_parameter" "transfer_classifier_repository_url" {
  name = var.transfer_classifier_repo_param_name
}
