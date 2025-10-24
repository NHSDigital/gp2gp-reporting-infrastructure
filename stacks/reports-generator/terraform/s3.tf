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
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
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
