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

provider "aws" {
  region = "eu-north-1"
}

# Data sources for reusability
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
