resource "aws_codepipeline" "main" {
  name          = "kaelnomads-frontend"
  role_arn      = aws_iam_role.codepipeline.arn
  pipeline_type = "V2" #V1 is normal, try V2 to save on costs, based only on run-time.

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        # Just do this manually and grab the codestar connection arn.
        ConnectionArn        = "arn:aws:codestar-connections:us-east-1:043038001148:connection/f2270e1c-8be3-42b0-900c-4a90db07d02c"
        FullRepositoryId     = "halexs/kaelnomads-js"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }

      namespace = "SourceVariables"
      region    = "us-east-1"
      run_order = 1
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

  }

  stage {
    name = "ManualProdApproval"
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

resource "aws_s3_bucket" "artifacts" {
  bucket        = "kaelnomads-artifact-bucket"
  force_destroy = true
}
