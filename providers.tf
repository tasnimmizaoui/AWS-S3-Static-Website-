terraform {
    required_version = ">= 1.5.0"
  required_providers {
    aws = { 
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources for reusability
data "aws_caller_identity" "current" {} 
data "aws_region" "current" {}
