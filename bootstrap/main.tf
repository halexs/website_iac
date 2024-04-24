terraform {
  backend "local" {
    path = "./terraform.state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "state" {
  bucket = "kaelnomads-terraform-state"

  tags = {
    Name        = "State Bucket"
  }

#   force_destroy = true
}
