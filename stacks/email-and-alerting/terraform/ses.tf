resource "aws_ses_email_identity" "email_report" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}
