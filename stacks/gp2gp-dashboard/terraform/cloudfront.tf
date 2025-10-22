locals {
  s3_origin_id = aws_s3_bucket.dashboard_website.id
}

data "aws_acm_certificate" "dashboard_certificate" {
  provider    = aws.cf_certificate_only_region
  domain      = var.alternate_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_distribution" "dashboard_s3_distribution" {
  aliases = [var.alternate_domain_name]

  origin {
    domain_name = aws_s3_bucket_website_configuration.dashboard_website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-GP2GP-service-dashboard"
      ApplicationRole = "AwsCloudfrontDistribution"
      PublicFacing    = "Y"
    }
  )

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.dashboard_certificate.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}
