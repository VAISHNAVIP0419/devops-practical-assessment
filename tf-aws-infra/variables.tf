# Input Variables for Terraform Infrastructure

# AWS Region - The region where all resources will be deployed
variable "aws_region" {
  type    = string
  default = "ap-south-1"
  description = "AWS region for resource deployment"
}

# Naming Prefix - Applied to all resource names for easy identification and management
variable "name_prefix" {
  type    = string
  default = "tf-assessment"
  description = "Prefix for all resource names (e.g., tf-assessment-vpc, tf-assessment-key)"
}

# SSH CIDR - CIDR blocks allowed for SSH access to bastion host
variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
  description = "CIDR block allowed for SSH access to bastion (restrict for security)"
}

# Keypair Creation - Whether to create a new keypair or use an existing one
variable "create_keypair" {
  description = "Whether to create a new EC2 key pair. If false, uses existing_key_name"
  type        = bool
  default     = false
}

# Existing Keypair Name - Used when create_keypair is false
variable "existing_key_name" {
  description = "Existing EC2 key pair name to use when not creating a new one"
  type        = string
  default     = "lab-key"
}

# Availability Zones - List of AZs for subnet distribution (for high availability)
variable "azs" {
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
  description = "List of Availability Zones for distributing subnets"
}

# VPC CIDR Block - The IP address range for the entire VPC
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC (supports 65,536 IP addresses)"
}

# Public Subnets - Subnets with internet access (will have IGW route)
variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of public subnet CIDR blocks (accessed from internet via IGW)"
}

# Private Subnets - Subnets without direct internet access (use NAT for outbound)
variable "private_subnets" {
  type        = list(string)
  default     = [
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
  description = "List of private subnet CIDR blocks (no direct internet access, use NAT for outbound)"
}

# NAT Gateway Creation - Whether to create NAT Gateway for private subnet internet access
variable "create_natgateway" {
  description = "Whether to create a NAT Gateway for outbound internet access from private subnets"
  type        = bool
  default     = true
}

# S3 Bucket Name - Custom bucket name for Terraform state storage
variable "create_bucket_name" {
  description = "If empty, S3 module will auto-generate bucket name using name_prefix + random suffix"
  type        = string
  default     = ""
}

# EC2 AMI - Amazon Machine Image ID for EC2 instances
variable "ami_id" {
  type        = string
  default     = "ami-02b8269d5e85954ef"
  description = "AMI ID for EC2 instances"
}

# Common Tags - Tags applied to all resources for identification and billing
variable "common_tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "student"
  }
  description = "Common tags applied to all resources"
}