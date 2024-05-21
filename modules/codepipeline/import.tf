
# # Import existing pipeline configurations
# resource "aws_codepipeline" "import" {
#   name          = "npm-deploy-code"
#   role_arn      = "arn:aws:iam::043038001148:role/service-role/AWSCodePipelineServiceRole-us-east-1-npm-deploy-code"
#   pipeline_type = "V1"


#   artifact_store {
#     location = "codepipeline-us-east-1-514535981285"
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeCommit"
#       version          = "1"
#       output_artifacts = ["SourceArtifact"]

#       configuration = {
#         PollForSourceChanges = "false"
#         RepositoryName       = "kaelnomads-frontend"
#         BranchName           = "main"
#         OutputArtifactFormat = "CODE_ZIP"
#       }

#       namespace = "SourceVariables"
#       region    = "us-east-1"
#       run_order = 1
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name     = "manual-trigger"
#       category = "Approval"
#       owner    = "AWS"
#       provider = "Manual"
#       version  = "1"
#     }

#     action {
#       name            = "Build"
#       category        = "Build"
#       owner           = "AWS"
#       provider        = "CodeBuild"
#       input_artifacts = ["SourceArtifact"]
#       version         = "1"

#       configuration = {
#         ProjectName = "kaelnomads-codebuild"
#       }
#       namespace = "BuildVariables"
#       output_artifacts = [
#         "BuildArtifact"
#       ]
#     }
#   }
# }

# resource "aws_codecommit_repository" "import" {
#   repository_name = "kaelnomads-frontend"
#   description     = "Frontend code for our website: https://kaelnomads.com/"
# }

# resource "aws_codebuild_project" "import" {
#   name           = "kaelnomads-codebuild"
#   build_timeout  = 20
#   service_role   = "arn:aws:iam::043038001148:role/service-role/codebuild-kaelnomads-codebuild-service-role"
#   encryption_key = "arn:aws:kms:us-east-1:043038001148:alias/aws/s3"
#   source_version = "refs/heads/main"

#   artifacts {
#     type           = "S3"
#     location       = "kaelnomads-resources"
#     name           = "codebuild-artifacts"
#     namespace_type = "BUILD_ID"

#   }

#   logs_config {
#     s3_logs {
#       location = "logs.kaelnomads.com/codebuild-"
#       status   = "ENABLED"
#     }
#   }

#   environment {
#     compute_type = "BUILD_GENERAL1_SMALL"
#     image        = "aws/codebuild/amazonlinux2-aarch64-standard:1.0"
#     type         = "ARM_CONTAINER"
#   }

#   source {
#     type            = "CODECOMMIT"
#     buildspec       = "aws_config/buildspec.yaml"
#     git_clone_depth = 1
#     location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/kaelnomads-frontend"
#     git_submodules_config {
#       fetch_submodules = false
#     }
#   }
# }