locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CreatedBy   = "Terraform"
    #Repository  = var.repository_url
  }
  
  # Content types mapping
  content_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "text/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
  }
  
  bucket_name = "${var.project_name}-${var.environment}-${random_pet.suffix.id}"
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${random_pet.suffix.id}"

  tags = {
    Project = var.project_name
    Env     = "dev"
  }
}

# Versionning for better file managment 
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id 
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Server side encryption : 
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id 
  rule  {
      apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
        bucket_key_enabled = true

  }
}
# Lifecycle configuration for cost optimization : 
# Old versions auto-delete after 30 days → controlled storage costs
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id 
  count = var.enable_lifecycle_rules ? 1 : 0
  rule { 
    id = "delete_old_versions" # create a rule named delete_old_versions
    status = "Enabled"         # sets it to active status 
    noncurrent_version_expiration {
    noncurrent_days = 30
  }
  }
  
  
}

# Website configuration 
resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.website.id

    index_document {
      suffix = var.index_document
    }

    error_document {
      key = var.error_document
    }
}


# Access control and securtiy  : 

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred" #Objects uploaded by other accounts/entities will be owned by the bucket owner (your AWS account)
  }
}
# aws_s3_bucket_public_access_block resource needs to be applied before the bucket policy
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false 
  block_public_policy     = false
  ignore_public_acls      = false # Allow our public policy 
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website,
    aws_s3_bucket_public_access_block.website,
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}

# Bucket policy for public read 
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website] # This was an addition after i encountered an error related to the public acess since terraform was trying to apply the policy before the bucket_acl configuration for public acess was done 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"  #path to objects inside the bucket 
      }
    ]
  }) 
}

# Cloud Front ditribution 
resource "aws_cloudfront_origin_access_control" "website" {
  count = var.enable_cloudfront ? 1 : 0
  name = "${local.bucket_name}-oac"
  description = "OAC for ${local.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  count               = var.enable_cloudfront ? 1 : 0
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.website[0].id
    origin_id                = "S3-${local.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.project_name}"
  default_root_object = var.index_document
  price_class         = var.cloudfront_price_class

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${local.bucket_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/${var.error_document}"
    error_caching_min_ttl = 300
  }

  tags = local.common_tags
}



# Upload website files : 
resource "aws_s3_object" "wensite_files" {
  for_each = fileset("${path.module}/website", "**/*")
  bucket = aws_s3_bucket.website.id 
  key = each.value
  source       = "${path.module}/website/${each.value}"
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), "binary/octet-stream")
  etag         = filemd5("${path.module}/website/${each.value}")

  # Add tags to objects
  tags = merge(local.common_tags, {
    FileType = lookup(local.content_types, regex("\\.[^.]+$", each.value), "binary/octet-stream")
  })
}

resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}


 #  Monitoring and logging : 
 # User Request → Source Bucket (website) → Access Log → Target Bucket (access-logs)
resource "aws_s3_bucket_logging" "website" {
  count =  var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket" "access_logs" {
  count = var.enable_access_logging ? 1 : 0
  bucket = "${local.bucket_name}-access-logs"
  force_destroy = var.force_destroy_bucket

  tags = merge(local.common_tags, {
    Purpose = "AccessLogs"
  })
}