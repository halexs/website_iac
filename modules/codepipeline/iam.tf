
resource "aws_iam_role" "codebuild" {
  name = "codepipeline-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codepipeline" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  for_each = toset(var.codebuild_policies)

  role = aws_iam_role.codebuild.name
  policy_arn = each.value
  
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  for_each = toset(var.codepipeline_policies)

  role = aws_iam_role.codepipeline.name
  policy_arn = each.value
}
