# Terraform Outputs - Export Resource Information
# S3 Bucket Name - For Terraform state and application data storage
output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "Name of the S3 bucket created for state storage"
}

# Application Instance Information - EC2 t3.medium instance details
output "app_instance_info" {
  value       = module.ec2_app.instance
  description = "Application EC2 instance information (ID, IP addresses, etc.)"
}

# Bastion Instance Information - Jump host details for SSH access
output "bastion_instance_info" {
  value       = module.ec2_bastion.instance
  description = "Bastion EC2 instance information (ID, public IP, etc.)"
}

# EBS Volume and Snapshot Information - Storage volume details
output "ebs_info" {
  value = {
    volume_id   = module.ebs.volume_id     # EBS volume ID (attached to app instance)
    snapshot_id = module.ebs.snapshot_id   # EBS snapshot ID (backup of volume)
  }
  description = "EBS volume and snapshot IDs"
}

# SSH Key Pair Information - For connecting to EC2 instances
output "keypair_info" {
  value = {
    key_name = module.keypair.key_name      # Key pair name used for SSH access
  }
  sensitive = false
  description = "SSH key pair name used for EC2 instances"
}

# VPC and Networking Information - Network infrastructure details
output "vpc_info" {
  value = {
    vpc_id             = module.vpc.vpc_id                      # VPC ID
    public_subnet_ids  = module.vpc.public_subnet_ids           # Public subnets (bastion deployed here)
    private_subnet_ids = module.vpc.private_subnet_ids          # Private subnets (app deployed here)
    nat_gateway_id     = module.vpc.nat_gateway_id              # NAT Gateway for private subnet internet
  }
  description = "VPC and subnet information"
}
