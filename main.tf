
# module "cicd_pipeline" {
#   source = "./modules/codepipeline"
# }

module "route53" {
  source = "./modules/route53"

  cert = module.s3_website.cert
}

module "s3_website" {
  source = "./modules/s3_website"
}
