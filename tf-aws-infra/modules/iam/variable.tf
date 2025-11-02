variable "name_prefix" {}
variable "bucket_name" {
  type = string
  default = ""
}
variable "bucket_arn" {
  type = string
  default = ""
}
variable "s3_bucket_arn" {
  type = string
  default = ""
  description = "Optional alias for bucket_arn - some callers use s3_bucket_arn"
}
variable "tags" {
  type = map(string)
  default = {}
}
