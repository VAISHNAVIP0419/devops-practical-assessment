# Key Name - Name of the key pair (new or existing)
output "key_name" {
  value       = var.create_key ? aws_key_pair.generated[0].key_name : var.existing_key
  description = "Key pair name (either newly generated or existing key provided)"
}

# Private Key PEM - The private key for SSH access (only for generated keys)
output "private_key_pem" {
  value       = var.create_key ? tls_private_key.key[0].private_key_pem : null
  description = "Private key PEM format (only available for newly generated keys, null for existing)"
  sensitive   = true  # Mark as sensitive to prevent logging
}