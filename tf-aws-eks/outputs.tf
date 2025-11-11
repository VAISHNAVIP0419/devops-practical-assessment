# EKS cluster name - used in: aws eks update-kubeconfig --cluster-name <value>
output "cluster_id" {
  description = "EKS cluster name for kubectl config"
  value       = module.eks.cluster_id
}

# Kubernetes API endpoint - used by kubectl for API calls
output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.eks.cluster_endpoint
}

# Certificate Authority data for secure API authentication
output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA certificate for cluster API"
  value       = module.eks.cluster_certificate_authority_data
}

