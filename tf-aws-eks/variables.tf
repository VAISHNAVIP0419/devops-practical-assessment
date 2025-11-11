# AWS region for EKS cluster deployment
variable "aws_region" {
  description = "AWS region (ap-south-1)"
  default     = "ap-south-1"
}

# VPC ID from tf-aws-infra outputs - cluster launches within existing VPC
variable "vpc_id" {
  description = "VPC ID for EKS cluster placement"
  default     = "vpc-061debf44eb7259d0"
}

# Private subnets for EKS nodes - isolated from internet
variable "private_subnet_ids" {
  description = "Private subnets for worker node placement"
  type        = list(string)
  default = [
    "subnet-06d0bcab2e359f091",
    "subnet-06422d3c5976557f9",
    "subnet-098fe6987f1cb5ae8",
    "subnet-0ba4802965d0281af"
  ]
}

# Public subnets for EKS control plane load balancer
variable "public_subnet_ids" {
  description = "Public subnets for ALB/NLB ingress controllers"
  type        = list(string)
  default = [
    "subnet-081f112d32f99942e",
    "subnet-058d890fccc268327"
  ]
}

# EKS cluster identifier - referenced in kubectl config
variable "cluster_name" {
  description = "EKS cluster name"
  default     = "tf-eks-cluster"
}

# Kubernetes version - latest recommended version
variable "cluster_version" {
  description = "Kubernetes version for EKS (latest stable)"
  default     = "1.30"
}

# EC2 instance type for worker nodes
variable "node_instance_type" {
  description = "Worker node instance type (t3.medium sufficient for 3-tier app)"
  default     = "t3.medium"
}
# node count 
variable "node_count" {
  description = "Number of worker nodes to create"
  default     = 2
}
