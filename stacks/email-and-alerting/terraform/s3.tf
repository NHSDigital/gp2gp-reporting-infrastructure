locals {
  gp2gp_inbox_storage_bucket_name = "prm-gp2gp-inbox-storage-${var.environment}"
}

resource "aws_s3_bucket" "gp2gp_inbox_storage" {
  bucket = local.gp2gp_inbox_storage_bucket_name

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [grant]
  }

  tags = merge(
    local.common_tags,
    {
      Name            = local.gp2gp_inbox_storage_bucket_name
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "gp2gp_inbox_storage" {
  bucket     = aws_s3_bucket.gp2gp_inbox_storage.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.email_and_alerting]
}

resource "aws_s3_bucket_ownership_controls" "email_and_alerting" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "gp2gp_inbox_storage" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "gp2gp_inbox_storage" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "gp2gp_inbox_storage_bucket_arn" {
  value = aws_s3_bucket.gp2gp_inbox_storage.arn
}
