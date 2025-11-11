# Availability Zone - Where the volume will be created
variable "availability_zone" {
  description = "AWS Availability Zone where the EBS volume will be created (e.g., ap-south-1a)"
  type        = string
}

# Volume Size - Storage capacity in GB
variable "size_gb" {
  type        = number
  default     = 8
  description = "Size of the EBS volume in GB"
}

# Common Tags - Tags to apply to volume and snapshot
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to EBS volume and snapshot"
}

