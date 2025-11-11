# TLS PRIVATE KEY GENERATION
# Generates an RSA private key using the TLS provider

# Conditional: only created if var.create_key = true
resource "tls_private_key" "key" {
  count     = var.create_key ? 1 : 0    # Create only if create_key = true
  algorithm = "RSA"                      # RSA encryption algorithm
  rsa_bits  = 4096                       # 4096-bit RSA key (strong security)
}


# Generates a random suffix for unique key pair name
resource "random_id" "random_suffix" {
  count       = var.create_key ? 1 : 0  # Create only if create_key = true
  byte_length = 4                        # 4 bytes = 8 hex characters
}


# Imports the public key into AWS as a key pair
# Conditional: only created if var.create_key = true
resource "aws_key_pair" "generated" {
  count      = var.create_key ? 1 : 0

  key_name   = "${var.name_prefix}-${random_id.random_suffix[0].hex}"  # Unique key name
  public_key = tls_private_key.key[0].public_key_openssh               # Public key from TLS
  tags       = var.tags
}