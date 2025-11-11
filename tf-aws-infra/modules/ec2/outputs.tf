# ===============================================
# EC2 Module Outputs
# ===============================================
# These outputs provide information about the created EC2 instance

# Instance Information - Complete instance details
output "instance" {
  value = {
    id         = aws_instance.this.id         # Instance ID (e.g., i-0123456789abcdef0)
    public_ip  = aws_instance.this.public_ip  # Public IP (only for instances in public subnet)
    private_ip = aws_instance.this.private_ip # Private IP (always available)
    key_name   = aws_instance.this.key_name   # SSH key pair name used
    tags       = aws_instance.this.tags       # All tags applied to instance
  }
  description = "EC2 instance information (ID, IPs, key name, tags)"
}
