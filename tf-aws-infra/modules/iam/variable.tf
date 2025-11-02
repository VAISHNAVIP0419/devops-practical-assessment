variable "name_prefix" {}
variable "bucket_name" {
  type = string
  default = ""
}
variable "bucket_arn" {
  type = string
  default = ""
}
variable "tags" {
  type = map(string)
  default = {}
}
