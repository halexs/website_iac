resource "random_string" "random" {
  # Buckets are vulnerable if the exact bucket name is known. Appending a random string to the end will protect against that.
  length  = 16
  special = false
}

locals {
  website_name   = "kaelnomads"
  website_domain = "${local.website_name}.com"
}

resource "aws_s3_bucket" "website" {
  # The bucket name for the website does not matter since it will have cloudfront to manage the distribution.
  bucket = "${local.website_name}-frontend-${random_string.random.result}"

  tags = {
    Name = "${local.website_domain}-frontend"
  }
}

resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = aws_s3_bucket.website.id

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
