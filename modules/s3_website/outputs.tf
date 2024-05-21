output "cert" {
  value = aws_acm_certificate.main
}

output "cloudfront" {
  value = aws_cloudfront_distribution.s3_website
}

output "cloudfront-dev" {
  value = aws_cloudfront_distribution.dev
}

output "s3_website_bucket" {
  value = aws_s3_bucket.website
}
