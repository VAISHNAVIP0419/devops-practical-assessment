terraform {
  required_version = ">= 1.5.0"

  # Providers: AWS for infrastructure, Kubernetes for kubectl, Helm for charts
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

  # Remote state backend - shared S3 bucket with tf-aws-infra
  backend "s3" {
    bucket = "tf-assessment-state-2cd3a1d0"  # Update with your S3 bucket
    key    = "eks/terraform.tfstate"          # Separate state for EKS
    region = "ap-south-1"
  }
}

# AWS provider for EKS, VPC, IAM resource creation
provider "aws" {
  region = var.aws_region
}
