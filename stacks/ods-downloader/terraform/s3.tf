resource "aws_s3_bucket" "ods_input" {
  bucket = "prm-gp2gp-asid-lookup-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-asid-lookup-used-to-supplement-ods-data"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "ods_input" {
  bucket = aws_s3_bucket.ods_input.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "ods_input" {
  bucket = aws_s3_bucket.ods_input.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "ods_output" {
  bucket = "prm-gp2gp-ods-metadata-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-organisational-metadata"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "ods_output" {
  bucket = aws_s3_bucket.ods_output.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "ods_output" {
  bucket = aws_s3_bucket.ods_output.id
  versioning_configuration {
    status = "Enabled"
  }
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