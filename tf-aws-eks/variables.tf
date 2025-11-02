variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-demo-cluster"
}

variable "k8s_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "tags" {
  type = map(string)
  default = {
    Owner       = "devops"
    Environment = "dev"
  }
}

# Your existing VPC details
variable "vpc_info" {
  description = "Existing VPC and subnet information"
  type = object({
    vpc_id             = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
    nat_gateway_id     = string
  })

  default = {
    vpc_id = "vpc-0dc7909c94b7d8f91"
    public_subnet_ids = [
      "subnet-083021794efb79599",
      "subnet-00e372543b73ce1c0"
    ]
    private_subnet_ids = [
      "subnet-02170e771ab117d3d",
      "subnet-08942aab8cd16de9e",
      "subnet-03fdc8832a9836b9c",
      "subnet-0d60442789fd48c90"
    ]
    nat_gateway_id = "nat-08fe7fda6ccab4015"
  }
}