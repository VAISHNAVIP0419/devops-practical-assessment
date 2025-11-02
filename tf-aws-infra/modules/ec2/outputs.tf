output "instance" {
  value = {
    id         = aws_instance.this.id
    public_ip  = aws_instance.this.public_ip
    private_ip = aws_instance.this.private_ip
    key_name   = aws_instance.this.key_name
    tags       = aws_instance.this.tags
  }
}
