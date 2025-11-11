# ===============================================
# S3 Module Variables
# ===============================================
# These variables define S3 bucket configuration

# Bucket Prefix - Used to generate unique bucket name
variable "bucket_prefix" {
  description = "Prefix for S3 bucket name (e.g., tf-assessment-state)"
  type        = string
}

# Bucket Name - Custom bucket name (optional)
variable "bucket_name" {
  type        = string
  default     = ""
  description = "Custom S3 bucket name. If empty, will auto-generate using prefix + random suffix"
}

# Force Destroy - Allow deletion of non-empty buckets
variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow Terraform to delete bucket even if it contains objects (useful for testing)"
}

# Common Tags - Tags to apply to bucket
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the S3 bucket"
}

# Versioning - Enable object versioning
variable "versioning" {
  type        = bool
  default     = false
  description = "Enable versioning for S3 bucket (protects state file from accidental deletion)"
}