resource "aws_acm_certificate" "main" {
  domain_name       = "kaelnomads.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "kaelnomads.com",
    "*.kaelnomads.com",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  #   s3_origin_id = "S3OriginId"
  s3_origin_id = "kaelnomads.com.s3.us-east-1.amazonaws.com"
}

resource "aws_cloudfront_distribution" "s3_website" {
  origin {
    domain_name = "kaelnomads.com.s3-website-us-east-1.amazonaws.com"

    origin_id = local.s3_origin_id

    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [
    "kaelnomads.com",
    "www.kaelnomads.com",
  ]

  default_cache_behavior {
    # allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    default_ttl      = 0
    max_ttl          = 0
    target_origin_id = local.s3_origin_id

    # Managed-CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
  }

  logging_config {
    bucket          = "kaelnomads-cloudfront-logs.s3.amazonaws.com" # variabilize
    include_cookies = false
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      #   restriction_type = "whitelist"
      #   locations        = ["US", "CA", "GB", "DE"]
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.main.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
