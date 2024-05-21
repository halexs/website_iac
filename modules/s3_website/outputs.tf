output "cert" {
  value = aws_acm_certificate.main
}

output "cloudfront" {
  value = aws_cloudfront_distribution.s3_website
}