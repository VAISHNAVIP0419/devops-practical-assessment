resource "tls_private_key" "key" {
  count     = var.create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "random_suffix" {
  count       = var.create_key ? 1 : 0
  byte_length = 4
}

resource "aws_key_pair" "generated" {
  count      = var.create_key ? 1 : 0

  key_name   = "${var.name_prefix}-${random_id.random_suffix[0].hex}"
  public_key = tls_private_key.key[0].public_key_openssh
  tags       = var.tags
}