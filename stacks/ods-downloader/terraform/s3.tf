resource "aws_s3_bucket" "ods_input" {
  bucket = "prm-gp2gp-asid-lookup-${var.environment}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "ASID lookup used to supplement ODS data"
    }
  )
}

resource "aws_s3_bucket" "ods_output" {
  bucket = "prm-gp2gp-ods-metadata-${var.environment}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Organisational metadata"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "ods_input" {
  bucket = aws_s3_bucket.ods_input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "ods_output" {
  bucket = aws_s3_bucket.ods_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}