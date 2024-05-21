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
