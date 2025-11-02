# VPC
# VPC
module "vpc" {
  source          = "./modules/vpc"
  name_prefix     = "${var.name_prefix}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  create_natgateway = var.create_natgateway
  tags            = var.common_tags
}

# Keypair (optional create)
module "keypair" {
  source         = "./modules/keypair"
  create_key     = var.create_keypair
  existing_key   = var.existing_key_name
  name_prefix    = "${var.name_prefix}-key"
  tags           = var.common_tags
}

# S3 (create bucket via module)
module "s3" {
  source        = "./modules/s3"
  bucket_prefix = "${var.name_prefix}-state"
  bucket_name   = var.create_bucket_name
  force_destroy = true
  tags          = var.common_tags
  versioning    = true
}

# IAM instance profile that allows EC2 to Get/Put in the bucket created
module "iam" {
  source      = "./modules/iam"
  name_prefix = "${var.name_prefix}-iam"
  bucket_name = module.s3.bucket_name
  bucket_arn  = module.s3.bucket_arn
  tags        = var.common_tags
}

# EBS (create volume + snapshot) - availability_zone uses first AZ
module "ebs" {
  source            = "./modules/ebs"
  availability_zone = var.azs[0]
  size_gb           = 8
  tags              = var.common_tags
}

# EC2 app instance (t3.medium) with EBS attached
module "ec2_app" {
  source                = "./modules/ec2"
  name                  = "tf-assessment-app"
  ami                   = ""
  instance_type         = "t3.medium"
  subnet_id             = element(module.vpc.private_subnet_ids, 0)
  security_group_ids    = [module.vpc.sg_app_id]
  key_name              = module.keypair.key_name
  instance_profile_name = module.iam.instance_profile_name
  attach_ebs            = true
  ebs_volume_id         = module.ebs.volume_id
  tags                  = var.common_tags
}

# Bastion host (t2.micro)
module "ec2_bastion" {
  source = "./modules/ec2"

  name                  = "${var.name_prefix}-bastion"
  ami                   = var.ami_id
  instance_type         = "t2.micro"
  subnet_id             = element(module.vpc.public_subnet_ids, 0)
  security_group_ids    = [module.vpc.bastion_sg_id]
  key_name              = module.keypair.key_name
  instance_profile_name = ""  # bastion doesn’t need IAM role
  attach_ebs            = false
  tags                  = var.common_tags
}
