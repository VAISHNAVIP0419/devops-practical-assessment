output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "List of private subnet IDs"
}

output "nat_gateway_id" {
  value       = var.create_natgateway ? aws_nat_gateway.nat[0].id : null
  description = "NAT Gateway ID (if created)"
}

output "sg_app_id" {
  value       = aws_security_group.default.id
  description = "App security group ID"
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "Bastion security group ID"
}
