resource "aws_s3_bucket" "platform_metrics_calculator" {
  bucket = "prm-gp2gp-platform-metrics-${var.environment}"
  acl    = "private"

  tags = merge(
    local.common_tags,
    {
      Name = "Raw spine data"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "platform_metrics_calculator" {
  bucket = aws_s3_bucket.platform_metrics_calculator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}