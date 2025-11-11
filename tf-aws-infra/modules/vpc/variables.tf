# VPC Name Prefix - Applied to all VPC-related resources
variable "name_prefix" {
  description = "Prefix name for VPC and related resources (e.g., vpc, igw, subnets)"
  type        = string
}

# VPC CIDR Block - The IP address range for the entire VPC
variable "cidr" {
  description = "CIDR block for VPC (e.g., 10.0.0.0/16)"
  type        = string
}

# Availability Zones - Geographic zones for subnet distribution
variable "azs" {
  description = "List of Availability Zones for distributing subnets (for high availability)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# Public Subnets - CIDR blocks for subnets with internet access
variable "public_subnets" {
  description = "List of public subnet CIDR blocks (will be routed to Internet Gateway)"
  type        = list(string)
}

# Private Subnets - CIDR blocks for subnets without direct internet access
variable "private_subnets" {
  description = "List of private subnet CIDR blocks (will be routed to NAT Gateway)"
  type        = list(string)
}

# Common Tags - Tags to apply to all VPC resources
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# NAT Gateway Creation - Whether to create NAT for private subnet internet access
variable "create_natgateway" {
  description = "Whether to create a NAT Gateway for outbound internet from private subnets"
  type        = bool
  default     = true
}
