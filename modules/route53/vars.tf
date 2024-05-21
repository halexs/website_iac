variable "cert" {
  type        = any
  description = "AWS Managed ACM Cert to be verified through route53 DNS."
}

variable "cloudfront" {
  type        = any
  description = "AWS Cloudfront distribution managing TLS/SSL cert for s3 website. Used mainly for a route53 record."
}
