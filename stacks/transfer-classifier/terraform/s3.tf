resource "aws_s3_bucket" "transfer_classifier" {
  bucket = "prm-gp2gp-transfer-data-${var.environment}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Output transfer data for metrics calculator and data analysis"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "transfer_classifier" {
  bucket = aws_s3_bucket.transfer_classifier.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
