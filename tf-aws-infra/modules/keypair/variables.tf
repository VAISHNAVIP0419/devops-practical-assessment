# Create Key - Whether to create a new key pair
variable "create_key" {
  type        = bool
  default     = false
  description = "Whether to create a new EC2 key pair. If false, uses existing_key"
}

# Existing Key - Name of pre-existing key pair to use
variable "existing_key" {
  type        = string
  default     = "lab-key"
  description = "Existing EC2 key pair name to use when create_key = false"
}

# Name Prefix - Applied to new key pair names
variable "name_prefix" {
  type        = string
  default     = "tf-key"
  description = "Prefix for generated key pair name (e.g., tf-key-a1b2c3d4)"
}

# Common Tags - Tags to apply to key pair
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the key pair"
}