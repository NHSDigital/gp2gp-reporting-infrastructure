resource "aws_s3_bucket" "gp2gp_inbox_storage" {
  bucket = "prm-gp2gp-inbox-storage-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-asid-email-attatchment-storage"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "gp2gp_inbox_storage_versioning" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [
    aws_s3_bucket.gp2gp_inbox_storage
  ]
}

resource "aws_s3_bucket_public_access_block" "gp2gp_inbox_storage" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}