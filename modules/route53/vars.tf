variable "cert" {
  type        = any
  description = "AWS Managed ACM Cert to be verified through route53 DNS."
}

variable "cloudfront" {
  type        = any
  description = "AWS Cloudfront distribution managing TLS/SSL cert for s3 website. Used mainly for a route53 record."
}

variable "cloudfront_dev" {
  type        = any
  description = "AWS Cloudfront distribution managing TLS/SSL cert for s3 website. Used mainly for a route53 record."
}

# variable "s3_website" {
#   type        = any
#   description = "AWS S3 bucket for the frontend website. Currently both the main and dev websites will be passed in as variables. Turns out this is not needed."
# }
