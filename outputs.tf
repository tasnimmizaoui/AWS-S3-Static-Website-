output "website_endpoint" {
  description = "The website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_domain
}
/*
output "website_url" {
  description = "The full website URL (http)"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}*/

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket_domain_name
}

# CloudFront outputs 
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_url" {
  description = "Full URL of the CloudFront distribution"
  value       = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : null
}

output "website_url" {
  description = "The main website URL (custom domain or CloudFront)"
  value = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"

}

# DEPLOYMENT INFO
# ================================================
output "deployment_info" {
  description = "Deployment information summary"
  value = {
    project_name   = var.project_name
    environment    = var.environment
    bucket_name    = aws_s3_bucket.website.id
    region         = data.aws_region.current.name
    account_id     = data.aws_caller_identity.current.account_id
    cloudfront_enabled = var.enable_cloudfront
    deployed_at    = timestamp()
  }
}

