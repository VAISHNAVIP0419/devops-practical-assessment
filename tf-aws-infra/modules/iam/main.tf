# IAM ROLE FOR EC2

resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.name_prefix}-ec2-s3-role"

  # Assume Role Policy - Allows EC2 service to assume this role
  # This trust policy is required for instance profiles
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allows EC2 service to assume this role
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # Only EC2 service can assume this role
        }
      }
    ]
  })

  tags = var.tags
}

# IAM ROLE POLICY - S3 ACCESS

# Inline policy that grants S3 permissions to the role
# Allows: GetObject and PutObject on the S3 bucket
# Restricts access to only the specific bucket (least privilege)
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.name_prefix}-s3-access"
  role = aws_iam_role.ec2_s3_role.id

  # Policy document defining S3 permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Grant S3 read/write permissions
        Effect = "Allow"
        Action = [
          "s3:GetObject",   # Read objects from S3 bucket
          "s3:PutObject"    # Write/upload objects to S3 bucket
        ]
        # Restrict to specific bucket and all objects in it
        Resource = [
          "${var.s3_bucket_arn != "" ? var.s3_bucket_arn : var.bucket_arn}/*"
        ]
      }
    ]
  })
}

# IAM INSTANCE PROFILE

# Instance profile is the bridge between EC2 and IAM role
# Attach this to EC2 instances to give them the role's permissions
# Without instance profile, EC2 cannot use the IAM role
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "${var.name_prefix}-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}