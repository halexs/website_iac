
resource "aws_codebuild_project" "dev" {
  name          = "codebuild-dev-deployment"
  description   = "Codebuild created using Terraform IaC. Will deploy and run the dev branch, and then the prod branch behind a Manual Approval"
  build_timeout = 30 # minutes
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.s3_website["dev"].bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./aws_codebuild/dev.yaml"
  }
}


resource "aws_codebuild_project" "prod" {
  name          = "codebuild-prod-deployment"
  description   = "Codebuild created using Terraform IaC. Will deploy and run the dev branch, and then the prod branch behind a Manual Approval"
  build_timeout = 30 # minutes
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.s3_website["main"].bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./aws_codebuild/prod.yaml"
  }
}
