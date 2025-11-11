# IAM Role ARN - Amazon Resource Name of the IAM role
output "role_arn" {
  value       = aws_iam_role.ec2_s3_role.arn
  description = "ARN of the IAM role for EC2 to assume"
}

# Instance Profile ARN - Amazon Resource Name of the instance profile
output "instance_profile_arn" {
  value       = aws_iam_instance_profile.ec2_s3_profile.arn
  description = "ARN of the instance profile (used to attach role to EC2)"
}

# Instance Profile Name - Name for reference in EC2 module
output "instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_s3_profile.name
  description = "IAM instance profile name - attach to EC2 instances"
}
