variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "name_prefix" {
  type    = string
  default = "tf-assessment"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "create_keypair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "existing_key_name" {
  description = "Existing key pair name to use when not creating"
  type        = string
  default     = "lab-key"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"] 
}

variable "private_subnets" {
  type    = list(string)
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}
variable "create_natgateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "create_bucket_name" {
  description = "If empty, module will create a bucket name using name_prefix and a random suffix"
  type = string
  default = ""
}

# EC2 AMI: optional override. If empty the ec2 module will lookup Amazon Linux 2 latest.
variable "ami_id" {
  type    = string
  default = "ami-02b8269d5e85954ef"
}

variable "common_tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "student"
  }
}