resource "aws_s3_bucket" "dashboard_website" {
  bucket = var.s3_dashboard_bucket_name

  tags = merge(
    local.common_tags,
    {
      Name            = "GP2GP-service-dashboard-s3-bucket"
      ApplicationRole = "AwsS3Bucket"
      PublicFacing    = "Y"
    }
  )

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [grant, website]
  }
}

resource "aws_s3_bucket_acl" "dashboard_website" {
  bucket = aws_s3_bucket.dashboard_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "dashboard_website" {
  bucket = aws_s3_bucket.dashboard_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}