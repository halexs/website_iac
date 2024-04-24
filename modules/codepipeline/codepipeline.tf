resource "aws_codepipeline" "main" {
  name     = "kaelnomads-frontend"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.main.bucket
    type     = "S3"

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.main.repository_name
        BranchName           = "main"
        PollForSourceChanges = false
        # Could potentially have multiple pipelines
      }
    }
  }

  stage {
    name = "DeployDevWebsite"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildDevArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev.name
      }
    }

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "DeployProdWebsite"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildProdArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.prod.name
      }
    }

  }
}

resource "aws_s3_bucket" "main" {
  bucket        = "kaelnomads-artifact-bucket"
  force_destroy = true
}

resource "aws_codecommit_repository" "main" {
  repository_name = "kaelnomads-js"
  description     = "Code that runs the pipeline when pushed"
}
