resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_terraform_state_bucket_name
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  # To cleanup old states eventually
  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 360
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-terraform-states-of-gp2gp-infrastructure"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "metrics_calculator" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "reports_generator" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

