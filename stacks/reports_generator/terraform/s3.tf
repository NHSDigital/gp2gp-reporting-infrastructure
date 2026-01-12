resource "aws_s3_bucket" "reports_generator" {
  bucket = "prm-gp2gp-reports-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-output-reports"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "reports_generator" {
  bucket     = aws_s3_bucket.reports_generator.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.reports_generator]
}

resource "aws_s3_bucket_ownership_controls" "reports_generator" {
  bucket = aws_s3_bucket.reports_generator.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "reports_generator" {
  bucket = aws_s3_bucket.reports_generator.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "reports_generator" {
  bucket = aws_s3_bucket.reports_generator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "report_metadata_example" {
  bucket       = aws_s3_bucket.reports_generator.id
  key          = "report_metadata_example.csv"
  content_type = "text/csv"

  metadata = {
    total-transfers                 = "11101"
    total-technical-failures        = "213"
    config-cutoff-days              = "0"
    report-name                     = "TRANSFER_DETAILS_BY_HOUR"
    reporting-window-end-datetime   = "2024-08-01T00:00:00+00:00"
    reporting-window-start-datetime = "2024-07-31T00:00:00+00:00"
    technical-failures-percentage   = "1.78"
    send-email-notification         = "True"
  }
}
