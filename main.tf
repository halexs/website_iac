
# module "cicd_pipeline" {
#   source = "./modules/codepipeline"
# }

module "route53" {
  source = "./modules/route53"
}
