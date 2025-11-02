resource "aws_instance" "this" {
  ami                    = var.ami != "" ? var.ami : "ami-0f58b397bc5c1f2e8"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile_name != "" ? var.instance_profile_name : null

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_volume_attachment" "ebs_attach" {
  count       = var.attach_ebs ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = var.ebs_volume_id
  instance_id = aws_instance.this.id
  force_detach = true
}