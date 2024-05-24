
module "cicd_pipeline" {
  source         = "./modules/codepipeline"
  s3_website     = module.website_s3.s3_website_bucket
  cloudfront_dev = module.website_s3.cloudfront-dev
}

module "route53" {
  source = "./modules/route53"

  cert           = module.website_s3.cert
  cloudfront     = module.website_s3.cloudfront
  cloudfront_dev = module.website_s3.cloudfront-dev
}

module "website_s3" {
  source = "./modules/website_s3"
}

module "website_backend" {
  source = "./modules/website_backend"
}

output "api_gw_url" {
  value = module.website_backend
}