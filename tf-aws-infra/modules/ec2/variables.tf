variable "name" {}
variable "ami" {
  type = string
  default = ""
}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "key_name" {
  type = string
  default = "lab-key"
}
variable "instance_profile_name" {
  type        = string
  default     = ""
  description = "IAM instance profile name"
}

variable "attach_ebs" {
  type = bool
  default = false
}
variable "ebs_volume_id" {
  type = string
  default = ""
}
variable "tags" {
  type = map(string)
  default = {}
}
