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
variable "enable_cloudfront" {
  description = "Enable CloudFront "
  type = bool
  default = true 
}
variable "cloudfront_price_class" {
   description = " Cloudfront  price class " 
    type        = string
   default     = "PriceClass_100"
}

# Logging and monitoring 
variable "enable_access_logging" {
  description = "Enable s3 bucket logging"
  type = bool

  
}

# MONITORING AND ALERTS
# ================================================
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address for CloudWatch alarms"
  type        = string
  default     = ""
}

# Other config 
variable "enable_compression" {
  description = "Enable gzip compression for text files"
  type        = bool
  default     = true
}