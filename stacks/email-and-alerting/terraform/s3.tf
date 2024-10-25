resource "aws_s3_bucket" "asid_storage" {
  bucket = "prm-gp2gp-asid-storage-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-asid-email-attatchment-storage"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "asid_storage_acl" {
  bucket = aws_s3_bucket.asid_storage.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "asid_storage_versioning" {
  bucket = aws_s3_bucket.asid_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}