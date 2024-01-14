# Main Terraform Configuration File

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# Backend Configuration for Terraform State Management
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-weatherapp"
    key            = "state/terraform.tfstate" # Desired path within the bucket
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-run-locks"
    encrypt        = true
  }
}
