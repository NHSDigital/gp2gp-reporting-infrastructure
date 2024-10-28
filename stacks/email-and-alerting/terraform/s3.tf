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

resource "aws_s3_bucket_acl" "gp2gp_inbox_storage_acl" {
  bucket = aws_s3_bucket.gp2gp_inbox_storage.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket.gp2gp_inbox_storage
  ]
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