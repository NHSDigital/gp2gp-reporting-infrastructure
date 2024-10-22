resource "aws_ses_email_identity" "email_report" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

resource "aws_s3_bucket" "gp2gp-inbox"{
  bucket = "${var.environment}-gp2gp-inbox"
}

resource "aws_ses_domain_identity" "gp2gp-inbox" {
  domain = "mail.${var.environment}.gp-registrations-data.nhs.uk"
}

resource "aws_ses_receipt_rule_set" "asid_lookup" {
  rule_set_name = "ingest-email"
}

resource "aws_ses_receipt_rule" "email_store" {
  name          = "email_store"
  rule_set_name = aws_ses_receipt_rule_set.asid_lookup.rule_set_name
  enabled       = true
  scan_enabled  = true
  s3_action {
    bucket_name = aws_s3_bucket.gp2gp_email_storage.id
    position    = 1
  }
}

data "aws_iam_policy_document" "SES-store-emails" {
  statement  {
      "Sid": "AllowSESPuts",
      "Effect": "Allow",
      "Principal": {
          "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": aws_s3_bucket.,
      "Condition": {
          "StringEquals": {
              "AWS:SourceAccount": local.account_id,
              "AWS:SourceArn": "arn:aws:ses:eu-west-2:${local.account_id}:receipt-rule-set/ROLE_NAME:receipt-rule/email_store"
          }
      }
  }
}