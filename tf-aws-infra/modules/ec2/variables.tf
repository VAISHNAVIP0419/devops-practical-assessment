# ===============================================
# EC2 Module Variables
# ===============================================
# These variables define EC2 instance configuration

# Instance Name - Friendly name for identification
variable "name" {
  description = "Name for the EC2 instance (applied as Name tag)"
  type        = string
}

# AMI - Amazon Machine Image ID
variable "ami" {
  type        = string
  default     = "ami-02b8269d5e85954ef"
  description = "AMI ID for the instance (Amazon Linux 2 by default)"
}

# Instance Type - Hardware specifications
variable "instance_type" {
  description = "EC2 instance type (e.g., t3.medium for app, t2.micro for bastion)"
  type        = string
}

# Subnet ID - Where the instance will be deployed
variable "subnet_id" {
  description = "VPC subnet ID where instance will be placed (public or private)"
  type        = string
}

# Security Group IDs - Network access control
variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to attach to instance"
}

# Key Pair Name - For SSH access
variable "key_name" {
  type        = string
  default     = "lab-key"
  description = "EC2 Key Pair name for SSH access"
}

# IAM Instance Profile - For AWS API access
variable "instance_profile_name" {
  type        = string
  default     = ""
  description = "IAM instance profile name for AWS API access (e.g., S3 permissions)"
}

# EBS Volume Attachment - Whether to attach additional storage
variable "attach_ebs" {
  type        = bool
  default     = false
  description = "Whether to attach an EBS volume to the instance"
}

# EBS Volume ID - The volume to attach
variable "ebs_volume_id" {
  type        = string
  default     = ""
  description = "EBS volume ID to attach (only used if attach_ebs = true)"
}

# Common Tags - For resource identification
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the EC2 instance"
}
