# ---------------- EKS Cluster Module ----------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"       # Official EKS module
  version = "~> 20.0"                             # Stable version

  # Cluster configuration
  cluster_name    = var.cluster_name               # EKS cluster name
  cluster_version = var.cluster_version            # Kubernetes version

  # Networking
  vpc_id     = var.vpc_id                          # VPC ID for cluster
  subnet_ids = var.private_subnet_ids              # Use private subnets

  # Control plane access
  cluster_endpoint_public_access = true            # Public API access enabled

  # Managed Node Group (fixed size - autoscaling removed)
  eks_managed_node_groups = {
    general = {
      desired_size = var.node_count                 # Fixed node count (no autoscaling)

      instance_types = [var.node_instance_type]     # EC2 type for nodes
      disk_size      = 20                           # Node disk size (GB)
    }
  }

  # Tags for identification
  tags = {
    Environment = "dev"                            # Environment name
    Terraform   = "true"                           # Managed by Terraform
    Owner       = "student"                        # Resource owner
  }
}
