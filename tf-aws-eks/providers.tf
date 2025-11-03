terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

   backend "s3" {
    bucket = "tf-assessment-state-2cd3a1d0" # your S3 bucket name
     key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}

# --- AWS Provider ---
provider "aws" {
  region = var.aws_region
}
