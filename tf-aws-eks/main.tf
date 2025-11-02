module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  # Cluster configuration
  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id  = var.vpc_info.vpc_id
  subnet_ids = var.vpc_info.private_subnet_ids

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    managed-nodes = {
      name = "managed-nodes"
      instance_types = ["t3.medium"]
      
      min_size     = 1
      desired_size = 2
      max_size     = 4

      subnet_ids = var.vpc_info.private_subnet_ids

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  tags = var.tags
}

# Data sources for cluster connection info
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority_data
}