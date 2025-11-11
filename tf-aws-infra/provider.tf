# ===============================================
# Terraform Provider Configuration
# ===============================================
# This file configures the required providers and versions

terraform {
  # Minimum Terraform version required for this configuration
  required_version = ">= 1.5.0"

  # Define all required providers and their versions
  required_providers {
    # AWS Provider - Used to manage all AWS resources (VPC, EC2, S3, IAM, EBS, etc.)
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    
    # TLS Provider - Used to generate RSA private keys for EC2 key pairs
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    
    # Random Provider - Used to generate random suffixes for unique resource names (S3 bucket)
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
  }
  }
  
  backend "s3" {
    bucket = "tf-assessment-state-2cd3a1d0"
    key    = "tf-aws-infra/terraform.tfstate"
    region = "ap-south-1"
  }
}

# Configure the AWS Provider
# The region is defined in variables.tf and can be overridden at runtime
provider "aws" {
  region = var.aws_region
}
