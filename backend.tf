/*
terraform {
  backend "s3" {
    bucket         = var.terraform_state_bucket
    key            = "static-website/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "${var.project_name}-${var.environment}-terraform-state-lock"
  }
}
--> This is eliminated for now since i will go for the Terraform Cloud approach 
*/
