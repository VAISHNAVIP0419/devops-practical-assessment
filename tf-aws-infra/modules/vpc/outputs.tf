# VPC ID - The unique identifier of the VPC
output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID - used to reference this VPC in other AWS resources"
}

# Public Subnet IDs - Subnets with internet access (for bastion host)
output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs - used for resources needing internet access (bastion)"
}

# Private Subnet IDs - Subnets without direct internet access (for app instance)
output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "List of private subnet IDs - used for internal resources (app instance, databases)"
}

# NAT Gateway ID - For reference if needed
output "nat_gateway_id" {
  value       = var.create_natgateway ? aws_nat_gateway.nat[0].id : null
  description = "NAT Gateway ID (null if NAT Gateway creation is disabled)"
}

# Application Security Group ID - For reference and modification
output "sg_app_id" {
  value       = aws_security_group.default.id
  description = "Security group ID for app instance (allows outbound, inbound can be added)"
}

# Bastion Security Group ID - For reference and modification
output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "Security group ID for bastion host (allows SSH port 22)"
}
