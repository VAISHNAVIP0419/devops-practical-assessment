variable "bucket_prefix" {}
variable "bucket_name" {
  type = string
  default = ""
}
variable "force_destroy" {
  type    = bool
  default = false
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "versioning" {
  type    = bool
  default = false
}