variable "availability_zone" {}
variable "size_gb" {
  type = number
  default = 8
}
variable "tags" {
  type = map(string)
  default = {}
}

