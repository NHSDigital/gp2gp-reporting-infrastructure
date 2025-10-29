import {
  to = aws_s3_bucket_acl.dashboard_website
  identity = {
    bucket = var.s3_dashboard_bucket_name
  }
}