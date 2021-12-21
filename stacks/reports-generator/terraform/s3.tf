resource "aws_s3_bucket" "reports_generator" {
  bucket = "prm-gp2gp-reports-${var.environment}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Output reports"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "reports_generator" {
  bucket = aws_s3_bucket.reports_generator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
