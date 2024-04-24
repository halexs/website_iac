
resource "aws_codebuild_project" "dev" {
  name          = "codebuild-dev-deployment"
  description   = "Codebuild created using Terraform IaC. Will deploy and run the dev branch, and then the prod branch behind a Manual Approval"
  build_timeout = 5 # minutes
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "node:21" # "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"
    # image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./aws_codebuild/dev.yaml"
  }
}


resource "aws_codebuild_project" "prod" {
  name          = "codebuild-prod-deployment"
  description   = "Codebuild created using Terraform IaC. Will deploy and run the dev branch, and then the prod branch behind a Manual Approval"
  build_timeout = 5 # minutes
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "node:21" # "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"
    # image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./aws_codebuild/prod.yaml"
  }
}
