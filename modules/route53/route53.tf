resource "aws_route53_zone" "main" {
  name    = "kaelnomads.com"
  comment = "HostedZone created by Route53 Registrar. Imported to Terraform."
}

# NS, SOA

# To import:
#  - (done) cloudfront, (done) cert, www.kaelnomads.com

resource "aws_route53_record" "cloudfront" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "kaelnomads.com"
  type    = "A"

  alias {
    name                   = var.cloudfront.domain_name
    zone_id                = var.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in var.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_route53_record" "s3_website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.kaelnomads.com"
  type    = "A"

  alias {
    name                   = aws_route53_record.cloudfront.name
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = false
  }
}

# Dev
resource "aws_route53_record" "cloudfront-dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.kaelnomads.com"
  type    = "A"

  alias {
    name                   = var.cloudfront_dev.domain_name
    zone_id                = var.cloudfront_dev.hosted_zone_id
    evaluate_target_health = false
  }
}
