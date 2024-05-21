resource "random_string" "random" {
  # Buckets are vulnerable if the exact bucket name is known. Appending a random string to the end will protect against that.
  #  S3 buckets must be lowercase and only a few special characters.
  length  = 16
  special = false
}

locals {
  website_name   = "kaelnomads"
  website_domain = "${local.website_name}.com"
  random_suffix  = lower(random_string.random.result) # s3 buckets can only be lowercase
  buckets        = ["main", "dev"]
}

resource "aws_s3_bucket" "website" {
  for_each = toset(local.buckets)

  # The bucket name for the website does not matter since it will have cloudfront to manage the distribution.
  bucket = "${local.website_name}-frontend-${each.value}-${local.random_suffix}"

  tags = {
    Name = "${local.website_domain}-frontend-${each.value}"
  }

  # force_destroy = true
}

output "test" {
  value = aws_s3_bucket.website
}

resource "aws_s3_bucket_public_access_block" "main" {
  for_each = aws_s3_bucket.website
  # Need to allow public access to S3 bucket before attaching website bucket policy.
  bucket = each.value.id

  block_public_policy     = false
  restrict_public_buckets = false
  block_public_acls       = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = aws_s3_bucket.website

  bucket = each.value.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${each.value.id}/*"
        }
      ]
    }
  )
  depends_on = [
    aws_s3_bucket_public_access_block.main
  ]
}

resource "aws_s3_bucket_website_configuration" "s3_website" {
  for_each = aws_s3_bucket.website

  bucket = each.value.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # routing_rule {
  #   condition {
  #     key_prefix_equals = "docs/"
  #   }
  #   redirect {
  #     replace_key_prefix_with = "documents/"
  #   }
  # }
}








# Dev website, so changes don't automatically update Prod

# resource "aws_s3_bucket" "website-dev" {
#   # The bucket name for the website does not matter since it will have cloudfront to manage the distribution.
#   bucket = "${local.website_name}-frontend-dev-${local.random_suffix}"

#   tags = {
#     Name = "${local.website_domain}-frontend-dev"
#   }
#   force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "dev" {
#   # Need to allow public access to S3 bucket before attaching website bucket policy.
#   bucket = aws_s3_bucket.website.id

#   block_public_policy     = false // This is default, so you can probably remove this line
#   restrict_public_buckets = false // same as above
#   block_public_acls       = true
#   ignore_public_acls      = true
# }

# resource "aws_s3_bucket_policy" "bucket_policy-dev" {
#   bucket = aws_s3_bucket.website.id
#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Sid" : "PublicReadGetObject",
#           "Effect" : "Allow",
#           "Principal" : "*",
#           "Action" : "s3:GetObject",
#           "Resource" : "arn:aws:s3:::${aws_s3_bucket.website.id}/*"
#         }
#       ]
#     }
#   )
#   depends_on = [
#     aws_s3_bucket_public_access_block.main
#   ]
# }

# resource "aws_s3_bucket_website_configuration" "s3_website-dev" {
#   bucket = aws_s3_bucket.website.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }

#   # routing_rule {
#   #   condition {
#   #     key_prefix_equals = "docs/"
#   #   }
#   #   redirect {
#   #     replace_key_prefix_with = "documents/"
#   #   }
#   # }
# }



# # Cloudfront purely for testing. Synced to the dev buckets
# resource "aws_cloudfront_distribution" "distribution" {
#   enabled         = true
#   is_ipv6_enabled = true

#   origin {
#     domain_name = aws_s3_bucket_website_configuration.s3_website["dev"].website_endpoint
#     origin_id   = aws_s3_bucket.website["dev"].bucket_regional_domain_name

#     custom_origin_config {
#       http_port                = 80
#       https_port               = 443
#       origin_keepalive_timeout = 5
#       origin_protocol_policy   = "http-only"
#       origin_read_timeout      = 30
#       origin_ssl_protocols = [
#         "TLSv1.2",
#       ]
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#       locations        = []
#     }
#   }

#   default_cache_behavior {
#     cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
#     viewer_protocol_policy = "redirect-to-https"
#     compress               = true
#     allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = aws_s3_bucket.website["dev"].bucket_regional_domain_name
#   }
# }

# output "cloudfront-dev" {
#   value = aws_cloudfront_distribution.distribution
# }