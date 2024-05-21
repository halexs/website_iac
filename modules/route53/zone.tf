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
    name                   = "df4covshu620a.cloudfront.net." # variabilize
    zone_id                = "Z2FDTNDATAQYW2"                # variabilize
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "tls_cert" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_85ae0902f62e18e61bd5b2bc5ef0e7bb.kaelnomads.com" # variabilize
  type    = "CNAME"
  ttl     = 300
  records = ["_a431f0e19002f1e9cddac99a140b64e9.yqdvztwmqr.acm-validations.aws."] # variabilize

}

resource "aws_route53_record" "s3_website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.kaelnomads.com"
  type    = "A"

  alias {
    name                   = "kaelnomads.com."
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = false
  }

}

