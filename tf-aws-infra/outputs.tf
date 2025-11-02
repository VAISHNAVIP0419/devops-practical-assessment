output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "app_instance_info" {
  value = module.ec2_app.instance
}

output "bastion_instance_info" {
  value = module.ec2_bastion.instance
}

output "ebs_info" {
  value = {
    volume_id   = module.ebs.volume_id
    snapshot_id = module.ebs.snapshot_id
  }
}

output "keypair_info" {
  value = {
    key_name = module.keypair.key_name
  }
  sensitive = false
}

output "vpc_info" {
  value = {
    vpc_id            = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    private_subnet_ids = module.vpc.private_subnet_ids
    nat_gateway_id    = module.vpc.nat_gateway_id
  }
}
