output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

output "alb_irsa_role_arn" {
  value = aws_iam_role.alb_irsa_role.arn
}

output "autoscaler_irsa_role_arn" {
  value = aws_iam_role.autoscaler_irsa_role.arn
}

output "vpc_id" {
  value = var.vpc_info.vpc_id
}

output "private_subnets" {
  value = var.vpc_info.private_subnet_ids
}