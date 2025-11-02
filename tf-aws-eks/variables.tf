# ----------- AWS Basic Configuration -----------
variable "aws_region" {
  default = "ap-south-1"
}

# ----------- VPC & Subnets from your infra output -----------
variable "vpc_id" {
  default = "vpc-0d25245f8ff004869"
}

variable "private_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0940f94afeee87734",
    "subnet-06599f80ba5134380",
    "subnet-0e8c746e53f5195c6",
    "subnet-0daac463704e71d1c"
  ]
}

variable "public_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0cf53e0aef986e280",
    "subnet-0bd10ae3d2371bd61"
  ]
}

# ----------- EKS Cluster Settings -----------
variable "cluster_name" {
  default = "tf-eks-cluster"
}

variable "cluster_version" {
  default = "1.30"
}

# ----------- Node Group Settings -----------
variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 4
}

variable "min_capacity" {
  default = 1
}
