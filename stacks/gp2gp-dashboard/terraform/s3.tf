resource "aws_s3_bucket" "dashboard_website" {
  bucket = var.s3_dashboard_bucket_name
  acl    = "public-read"

  tags = merge(
    local.common_tags,
    {
      Name = "GP2GP-service-dashboard-s3-bucket"
      ApplicationRole = "AwsS3Bucket"
      PublicFacing        = "Y"
    }
  )

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}
