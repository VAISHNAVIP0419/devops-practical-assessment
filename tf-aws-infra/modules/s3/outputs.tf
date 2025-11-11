# ===============================================
# S3 Module Outputs
# ===============================================
# These outputs provide S3 bucket information for use by other modules

# Bucket Name - For reference and use by other services
output "bucket_name" {
  value       = aws_s3_bucket.this.id
  description = "S3 bucket name - used as reference and for IAM policy"
}

# Bucket ARN - For IAM policies and permissions
output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "S3 bucket ARN - used in IAM policies to grant EC2 access"
}
