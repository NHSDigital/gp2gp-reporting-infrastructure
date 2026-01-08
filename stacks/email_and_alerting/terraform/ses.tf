locals {
  ses_domain = "mail.${var.hosted_zone_name}"
}

data "aws_ssm_parameter" "asid_lookup_address_prefix" {
  name = var.asid_lookup_inbox_prefix_param_name
}

resource "aws_ses_email_identity" "gp2gp_inbox_sender_address" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

moved {
  from = aws_ses_email_identity.email_report
  to   = aws_ses_email_identity.gp2gp_inbox_sender_address
}

resource "aws_ses_domain_identity" "gp2gp_inbox" {
  domain = local.ses_domain
}

resource "aws_ses_receipt_rule_set" "gp2gp_inbox" {
  rule_set_name = "gp2gp-inbox-rules-${var.environment}"
}

resource "aws_ses_active_receipt_rule_set" "active_rule_set" {
  rule_set_name = aws_ses_receipt_rule_set.gp2gp_inbox.rule_set_name
}

resource "aws_ses_receipt_rule" "asid_lookup" {
  name          = local.ses_receipt_rule_asid_lookup_name
  rule_set_name = aws_ses_receipt_rule_set.gp2gp_inbox.rule_set_name
  enabled       = true
  scan_enabled  = true
  recipients    = ["${data.aws_ssm_parameter.asid_lookup_address_prefix.value}@${local.ses_domain}"]

  s3_action {
    bucket_name       = aws_s3_bucket.gp2gp_inbox_storage.id
    object_key_prefix = "asid_lookup/"
    position          = 1
  }

  lambda_action {
    function_arn    = aws_lambda_function.store_asid_lookup.arn
    invocation_type = "Event"
    position        = 2
  }

  depends_on = [
    aws_s3_bucket_policy.gp2gp_inbox_storage,
    aws_lambda_permission.store_asid_lookup_ses_trigger
  ]
}

resource "aws_ses_domain_dkim" "gp2gp_inbox_domain_identification" {
  domain = aws_ses_domain_identity.gp2gp_inbox.domain
}

resource "aws_route53_record" "gp2gp_inbox_dkim_records" {
  count   = 3
  zone_id = data.aws_route53_zone.gp_registrations.zone_id
  name    = "${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}._domainkey.${local.ses_domain}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${aws_ses_domain_dkim.gp2gp_inbox_domain_identification.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "gp2gp_inbox_dmarc" {
  zone_id = data.aws_route53_zone.gp_registrations.zone_id
  name    = "_dmarc.${local.ses_domain}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none;"
  ]
}