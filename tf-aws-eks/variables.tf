# ----------- AWS Basic Configuration -----------
variable "aws_region" {
  default = "ap-south-1"
}

# ----------- VPC & Subnets from your infra output -----------
variable "vpc_id" {
  default = "vpc-061debf44eb7259d0"
}

variable "private_subnet_ids" {
  type = list(string)
  default = [
    "subnet-06d0bcab2e359f091",
    "subnet-06422d3c5976557f9",
    "subnet-098fe6987f1cb5ae8",
    "subnet-0ba4802965d0281af"
  ]
}

variable "public_subnet_ids" {
  type = list(string)
  default = [
    "subnet-081f112d32f99942e",
    "subnet-058d890fccc268327"
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
