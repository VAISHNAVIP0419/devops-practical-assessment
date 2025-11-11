# 1. VPC MODULE - Creates the network infrastructure
# Creates VPC with public and private subnets, Internet Gateway, NAT Gateway
module "vpc" {
  source          = "./modules/vpc"
  name_prefix     = "${var.name_prefix}-vpc"  # VPC naming and CIDR configuration
  cidr            = var.vpc_cidr
  azs             = var.azs                   # Availability zones and subnet configuration
  public_subnets  = var.public_subnets        # Subnets with internet access (via IGW)
  private_subnets = var.private_subnets       # Subnets without direct internet (use NAT)
  create_natgateway = var.create_natgateway   # NAT Gateway for private subnet outbound internet access
  tags            = var.common_tags           
}

# 2. KEYPAIR MODULE - Creates or references SSH key pairs
# Either creates a new EC2 key pair or uses an existing one
module "keypair" {
  source         = "./modules/keypair"
  
  # Whether to generate new key or use existing
  create_key     = var.create_keypair
  existing_key   = var.existing_key_name  # Key name used if create_key = false
  
  # Naming for new key
  name_prefix    = "${var.name_prefix}-key"
  
  # Tags for resource identification
  tags           = var.common_tags
}

# 3. S3 MODULE - Creates S3 bucket for Terraform state storage
module "s3" {
  source        = "./modules/s3"
  bucket_prefix = "${var.name_prefix}-state"   # Bucket naming
  bucket_name   = var.create_bucket_name
  force_destroy = true    # Allows Terraform to delete bucket (useful for testing/cleanup)
  versioning    = true    # Enable versioning for state file backup and recovery
  tags          = var.common_tags
}

# 4. IAM MODULE - Creates EC2 instance profile with S3 access

module "iam" {
  source      = "./modules/iam"
  name_prefix = "${var.name_prefix}-iam" # Naming for IAM resources
  bucket_name = module.s3.bucket_name    # S3 bucket name from s3 module output
  bucket_arn  = module.s3.bucket_arn     # S3 bucket ARN for policy resource definition
  s3_bucket_arn = module.s3.bucket_arn   # Alias for bucket_arn (supports both naming conventions)
 tags        = var.common_tags
}

# 5. EBS MODULE - Creates EBS volume and snapshot
module "ebs" {
  source            = "./modules/ebs"
  availability_zone = var.azs[0]         # Uses first AZ from azs list
  size_gb           = 8                   # Volume size in GB
  tags              = var.common_tags
}

# 6. EC2 APPLICATION INSTANCE - t3.medium with EBS attached

module "ec2_app" {
  source                = "./modules/ec2"
  name                  = "tf-assessment-app"
  instance_type         = "t3.medium"      # General purpose instance with 2 vCPU, 4GB RAM
  ami                   = "ami-02b8269d5e85954ef"
  subnet_id             = element(module.vpc.private_subnet_ids, 0)  # First private subnet
  security_group_ids    = [module.vpc.sg_app_id]   # App security group from VPC module
  key_name              = module.keypair.key_name  # SSH key from keypair module
  
  # IAM role for AWS API access (S3 permissions)
  instance_profile_name = module.iam.instance_profile_name
  
  # EBS volume attachment
  attach_ebs            = true             # Attach EBS volume
  ebs_volume_id         = module.ebs.volume_id     # 8GB volume from ebs module
  tags                  = var.common_tags
}

# 7. EC2 BASTION HOST - t2.micro for SSH access
# Jump host deployed in public subnet for secure SSH access to private instances
module "ec2_bastion" {
  source = "./modules/ec2"
  # Instance naming and type
  name                  = "${var.name_prefix}-bastion"
  instance_type         = "t2.micro"       # Cost-optimized for bastion (1 vCPU, 1GB RAM)
  ami                   = "ami-02b8269d5e85954ef" 
  
  # Network configuration
  subnet_id             = element(module.vpc.public_subnet_ids, 0)  # First public subnet
  security_group_ids    = [module.vpc.bastion_sg_id]   # Bastion security group (SSH only)
  
  # SSH access configuration
  key_name              = module.keypair.key_name  # Same key as app instance
  
  # Bastion does not need IAM role or EBS volume
  instance_profile_name = ""    # No S3 access needed for bastion
  attach_ebs            = false # No additional storage needed
  
  # Tags for resource identification
  tags                  = var.common_tags
}
