# ALB Controller Policy
resource "aws_iam_policy" "alb_controller_policy" {
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = file("${path.module}/iam-policy-alb.json")
}

# ALB IRSA Role
resource "aws_iam_role" "alb_irsa_role" {
  name = "${var.cluster_name}-alb-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_irsa_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# Cluster Autoscaler Policy
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name   = "${var.cluster_name}-cluster-autoscaler-policy"
  policy = file("${path.module}/iam-policy-autoscaler.json")
}

resource "aws_iam_role" "autoscaler_irsa_role" {
  name = "${var.cluster_name}-autoscaler-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaler_attach" {
  role       = aws_iam_role.autoscaler_irsa_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}