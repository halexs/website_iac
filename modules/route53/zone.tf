resource "aws_route53_zone" "main" {
  name    = "kaelnomads.com"
  comment = "HostedZone created by Route53 Registrar. Imported to Terraform."
}

# NS, SOA

# To import:
#  - cloudfront, cert, www.kaelnomads.com

resource "aws_route53_record" "cloudfront" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "kaelnomads.com"
  type    = "A"

  alias {
    name                   = "df4covshu620a.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

