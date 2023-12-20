# Main Terraform Configuration File

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# Backend Configuration for Terraform State Management
# This section is currently commented out but can be used to configure
# a remote backend for Terraform using an S3 bucket. This is useful for 
# team environments where sharing state is necessary.

/*
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "path/to/my/key"
    region = "us-east-1"
    
    # Additional optional configurations:
    # encrypt        = true               # Enable encryption for the state file
    # acl            = "private"          # Access control settings
    # dynamodb_table = "my-lock-table"    # DynamoDB table for state locking
    # ...
  }
}
*/
