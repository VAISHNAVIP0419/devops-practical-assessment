output "key_name" {
  value       = var.create_key ? aws_key_pair.generated[0].key_name : var.existing_key
  description = "Key pair name (existing or generated)"
}

output "private_key_pem" {
  value       = var.create_key ? tls_private_key.key[0].private_key_pem : null
  description = "Private key PEM (only for generated key)"
  sensitive   = true
}