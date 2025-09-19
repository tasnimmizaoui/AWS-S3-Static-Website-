variable "aws_region" {
    description = "AWS region to deploy into"
    type = string
    default = ""
  
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "s3-static-site"
}
variable "environment" {
  description = "Environment "
  type        = string
  default     = "dev"
  
}
variable "owner" {
  description = "The  owner of the ressources  "
  type        = string
  default     = "Devops Team "
  
}
variable "enable_cloudfront" {
   # To fill 
}

variable "cloudfront_price_class" {
   # To fill 
}

variable "index_document" {
  description = "Default index page"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Default error page"
  type        = string
  default     = "error.html"
}
# S3 bucket configuration 
variable "force_destroy_bucket" {
  description = "Allow Terraform to destroy the bucket even if it contains objects"
  type        = bool
  default     = true # Set to false in production!
}
variable "enable_versioning" {
  description = "S3 bucket versionnning status"
  type = bool
  default = true
}

variable "enable_lifecycle_rules" {
  description = "Enable S3 lifecycle rules for cost optimization"
  type = bool
  default = true 
  
}
# CloudFront configuration 
variable "enbale_cloudfront" {
  description = "Enable CloudFront "
  type = bool
  default = true 
}

