locals {
  s3_origin_id = aws_s3_bucket.dashboard_website.id
}

data "aws_acm_certificate" "dashboard_certificate" {
  region      = "us-east-1"
  domain      = var.alternate_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_distribution" "dashboard_s3_distribution" {
  aliases = [var.alternate_domain_name]

  origin {
    domain_name                 = aws_s3_bucket.dashboard_website.bucket_regional_domain_name
    origin_id                   = local.s3_origin_id
    response_completion_timeout = 0
    origin_access_control_id    = aws_cloudfront_origin_access_control.dashboard.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.append_index_html.arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
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

resource "aws_cloudfront_origin_access_control" "dashboard" {
  name                              = "dashboard_s3_oac_policy"
  description                       = "CloudFront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "append_index_html" {
  name    = "rewrite-index-html"
  runtime = "cloudfront-js-2.0"
  comment = "Appends index.html to subfolder requests"
  publish = true
  code    = <<EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Append index.html if the URI ends with /
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } 
    // Append /index.html if the URI has no extension (a folder)
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
EOF
}
