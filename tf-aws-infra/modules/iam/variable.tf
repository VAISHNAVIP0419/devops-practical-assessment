# Name Prefix - Applied to IAM role and profile names
variable "name_prefix" {
  description = "Prefix for IAM role and instance profile names"
  type        = string
}

# Bucket Name - S3 bucket to grant access to (optional)
variable "bucket_name" {
  type        = string
  default     = ""
  description = "Name of the S3 bucket (optional, used for reference)"
}

# Bucket ARN - S3 bucket ARN for policy resource definition (primary parameter)
variable "bucket_arn" {
  type        = string
  default     = ""
  description = "ARN of the S3 bucket to grant GetObject/PutObject access to"
}

# S3 Bucket ARN - Alias for bucket_arn (supports both naming conventions)
variable "s3_bucket_arn" {
  type        = string
  default     = ""
  description = "Optional alias for bucket_arn - some callers use s3_bucket_arn"
}

# Common Tags - Tags to apply to IAM resources
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to IAM resources"
}
