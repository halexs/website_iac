
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
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
  ]
}

variable "s3_website" {
  type        = any
  description = "AWS S3 bucket for the frontend website. Currently both the main and dev websites will be passed in as variables. Used to put the bucket names in environment variables for codebuild."
}

variable "cloudfront_dev" {
  type        = any
  description = "AWS Cloudfront distribution managing TLS/SSL cert for s3 website. Used mainly for the buildspec environment variable to allow cache invalidation."
}

variable "api_gw_url" {
  type        = any
  description = "API Gateway url to access the lambda function. Used for the CICD pipeline."
  default     = ""
}