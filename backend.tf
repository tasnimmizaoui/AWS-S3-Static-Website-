terraform {
  cloud {
    organization = "hungryheidi"

    workspaces {
      name = "AWS-S3-Static-Website"
    }
  }

  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
