
resource "aws_ses_email_identity" "gp2gp_inbox_sender_address" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

resource "aws_ses_domain_identity" "gp2gp_inbox" {
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

  depends_on = [aws_ses_receipt_rule_set.asid_email_storage_rules]
}

resource "aws_ses_domain_dkim" "gp2gp_inbox_domain_identification" {
  domain = aws_ses_domain_identity.gp2gp_inbox.domain

  depends_on = [aws_ses_domain_identity.gp2gp_inbox]
}

resource "aws_route53_record" "ndr_ses_dkim_record" {
  count   = 3
  zone_id = var.zone_id # TODO: Find where this is configured in tf and set as output, otherwise may need to add SSM param as we are not in control of domain
  name    = "${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}._domainkey.${var.ses_domain}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [aws_ses_domain_dkim.gp2gp_inbox_domain_identification]
}

resource "aws_route53_record" "dmarc_record" {
  zone_id = var.zone_id
  name    = "_dmarc.${var.ses_domain}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none;"
  ]
}