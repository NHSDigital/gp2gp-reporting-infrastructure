resource "aws_ses_email_identity" "email_report" {
  email = var.email_report_sender_email_param_name
}