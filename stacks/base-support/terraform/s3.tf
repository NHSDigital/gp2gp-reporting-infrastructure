resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_terraform_state_bucket_name
  acl    = "private"

  # To allow rolling back states
  versioning {
    enabled = true
  }

  # To cleanup old states eventually
  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 360
    }
  }

  tags = {
    Name = "Terraform states of GP2GP infrastructure"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
