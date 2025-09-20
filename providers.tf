provider "aws" {
  region = "eu-north-1"
}

# Data sources for reusability
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
