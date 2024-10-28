
resource "aws_ses_email_identity" "gp2gp_inbox_sender_address" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

resource "aws_ses_domain_identity" "gp2gp_inbox" {
  domain = var.ses_domain
}

resource "aws_ses_receipt_rule_set" "gp2gp_inbox_rules" {
  rule_set_name = "gp2gp-inbox-${var.environment}"
}

resource "aws_ses_receipt_rule" "store_email_in_s3_rule" {
  name          = "gp2gp-store-email-in-s3-${var.environment}"
  rule_set_name = aws_ses_receipt_rule_set.gp2gp_inbox_rules.rule_set_name
  enabled       = true
  scan_enabled  = true
  s3_action {
    bucket_name = aws_s3_bucket.gp2gp_inbox_storage.id
    position    = 1
  }

  depends_on = [aws_ses_receipt_rule_set.gp2gp_inbox_rules]
}

resource "aws_ses_domain_dkim" "gp2gp_inbox_domain_identification" {
  domain = aws_ses_domain_identity.gp2gp_inbox.domain

  depends_on = [aws_ses_domain_identity.gp2gp_inbox]
}

resource "aws_route53_record" "gp2gp_inbox_dkim_record" {
  count   = 3
  zone_id = data.aws_ssm_parameter.hosted_zone_id.id
  name    = "${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}._domainkey.${var.ses_domain}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [aws_ses_domain_dkim.gp2gp_inbox_domain_identification]
}

resource "aws_route53_record" "gp2gp_inbox_dmarc_record" {
  zone_id = data.aws_ssm_parameter.hosted_zone_id.id
  name    = "_dmarc.${var.ses_domain}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none;"
  ]
}