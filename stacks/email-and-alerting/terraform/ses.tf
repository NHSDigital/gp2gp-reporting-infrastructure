
resource "aws_ses_email_identity" "gp2gp_inbox_sender_address" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

resource "aws_ses_domain_identity" "gp2gp_inbox_domain" {
  domain = var.ses_domain
}

resource "aws_ses_receipt_rule_set" "asid_email_storage_rules" {
  rule_set_name = "gp2gp-asid-email-storage-${var.environment}"
}

resource "aws_ses_receipt_rule" "store_asid_email_in_s3_rule" {
  name          = "gp2gp-store-asid-email-in-s3-${var.environment}"
  rule_set_name = aws_ses_receipt_rule_set.asid_email_storage_rules.rule_set_name
  enabled       = true
  scan_enabled  = true
  s3_action {
    bucket_name = aws_s3_bucket.asid_storage.id
    position    = 1
  }
}