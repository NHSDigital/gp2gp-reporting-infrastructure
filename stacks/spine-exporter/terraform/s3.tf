resource "aws_s3_bucket" "spine_exporter" {
  bucket = "prm-gp2gp-raw-spine-data-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Raw spine data"
    }
  )
}

resource "aws_s3_bucket_acl" "spine_exporter" {
  bucket = aws_s3_bucket.spine_exporter.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "spine_exporter" {
  bucket = aws_s3_bucket.spine_exporter.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}