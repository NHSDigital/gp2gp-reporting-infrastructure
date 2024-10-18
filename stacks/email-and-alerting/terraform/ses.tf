resource "aws_ses_email_identity" "email_report" {
  email = data.aws_ssm_parameter.email_report_sender_email.value
}

resource "aws_s3_bucket" "gp2gp_email_storage"{
  bucket = "gp2gp_email_storage"
}

resource "aws_ses_domain_identity" "gp2gp_email_inbox" {
  domain = "mail.dev.gp-registrations-data.nhs.uk"
}

resource "aws_ses_receipt_rule_set" "asid_lookup" {
  rule_set_name = "ingest-email"
}

resource "aws_ses_receipt_rule" "email_store" {
  name          = "email_store"
  rule_set_name = "default-rule-set"
  enabled       = true
  scan_enabled  = true
  s3_action {
    bucket_name = "gp2gp_email_storage"
    position    = 1
  }
}

data "aws_iam_policy_document" "example" {
  statement  {
      "Sid": "AllowSESPuts",
      "Effect": "Allow",
      "Principal": {
          "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::gp2gp-email-storage/*",
      "Condition": {
          "StringEquals": {
              "AWS:SourceAccount": local.account_id,
              "AWS:SourceArn": "arn:aws:ses:eu-west-2:${local.account_id}:receipt-rule-set/ROLE_NAME:receipt-rule/email_store"
          }
      }
  }
}