
# module "cicd_pipeline" {
#   source = "./modules/codepipeline"
# }

module "route53" {
  source = "./modules/route53"

  cert           = module.s3_website.cert
  cloudfront     = module.s3_website.cloudfront
  cloudfront_dev = module.s3_website.cloudfront-dev
  # s3_website     = module.s3_website.s3_website_bucket
}

module "s3_website" {
  source = "./modules/s3_website"
}
