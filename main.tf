
# module "cicd_pipeline" {
#   source = "./modules/codepipeline"
# }

module "route53" {
  source = "./modules/route53"

  cert       = module.s3_website.cert
  cloudfront = module.s3_website.cloudfront
}

module "s3_website" {
  source = "./modules/s3_website"
}

output "see_output" {
  value = module.s3_website.cloudfront
}
