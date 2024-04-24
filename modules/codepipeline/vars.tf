
variable "codepipeline_policies" {
  type = list(string)

  description = "A list of policies that will be attached to the AWS Codepipeline service account in order to run the pipeline."

  default = [ 
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

variable "codebuild_policies" {
  type = list(string)

  description = "A list of policies that will be attached to the AWS Codebuild service account in order to run jobs."

  default = [ 
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",

  ]
}
