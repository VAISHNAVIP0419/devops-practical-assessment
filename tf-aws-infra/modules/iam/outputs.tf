output "role_arn" {
  value = aws_iam_role.ec2_s3_role.arn
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_s3_profile.arn
}
output "instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_s3_profile.name
  description = "IAM instance profile name"
}
