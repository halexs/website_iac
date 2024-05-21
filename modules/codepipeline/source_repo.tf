
resource "aws_codecommit_repository" "main" {
  repository_name = "kaelnomads-js"
  description     = "Code that runs the pipeline when pushed"
}

# arn:aws:codestar-connections:us-east-1:043038001148:connection/f2270e1c-8be3-42b0-900c-4a90db07d02c