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

