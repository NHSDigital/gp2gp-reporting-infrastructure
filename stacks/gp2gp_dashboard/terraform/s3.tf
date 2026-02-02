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

resource "aws_s3_bucket_ownership_controls" "dashboard_website" {
  bucket = aws_s3_bucket.dashboard_website.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
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

resource "aws_s3_bucket_policy" "dashboard_website" {
  bucket = aws_s3_bucket.dashboard_website.id
  policy = data.aws_iam_policy_document.dashboard_website.json
}

data "aws_iam_policy_document" "dashboard_website" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.dashboard_website.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.dashboard_s3_distribution.arn]
    }
  }
}
