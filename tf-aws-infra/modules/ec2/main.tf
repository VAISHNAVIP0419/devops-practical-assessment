# EC2 INSTANCE CREATION
resource "aws_instance" "this" {
  # Operating System Image
  ami                    = var.ami != "" ? var.ami : "ami-02b8269d5e85954ef"  # Amazon Linux 2 if not specified
  # Instance Configuration
  instance_type          = var.instance_type         # t3.medium for app, t2.micro for bastion
  subnet_id              = var.subnet_id             # Deploy in specific subnet (public or private)
  vpc_security_group_ids = var.security_group_ids   # Apply security groups for network access control
  key_name               = var.key_name              # SSH key pair for remote access
  iam_instance_profile   = var.instance_profile_name != "" ? var.instance_profile_name : null  # IAM role (for S3 access, etc.)

  tags = merge(var.tags, { Name = var.name })
}

# EBS VOLUME ATTACHMENT
# Conditionally attaches an EBS volume to the instance
# Used for app instance (attach=true), not used for bastion
resource "aws_volume_attachment" "ebs_attach" {
  count        = var.attach_ebs ? 1 : 0              # Create only if attach_ebs = true
  device_name  = "/dev/sdh"                          # Linux device name for volume
  volume_id    = var.ebs_volume_id                   # EBS volume to attach
  instance_id  = aws_instance.this.id                # EC2 instance to attach to
  force_detach = true                                # Allow detachment even if in use
}