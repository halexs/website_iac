terraform {
  backend "s3" {
    bucket = "kaelnomads-terraform-state"
    key    = "website-js"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

