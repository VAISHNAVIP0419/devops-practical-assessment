variable "create_key" {
  type    = bool
  default = false
}

variable "existing_key" {
  type    = string
  default = "lab-key"
}

variable "name_prefix" {
  type    = string
  default = "tf-key"
}

variable "tags" {
  type    = map(string)
  default = {}
}