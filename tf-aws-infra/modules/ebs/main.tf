resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size_gb
  tags              = merge(var.tags, { Name = "tf-ebs-volume" })
}

resource "aws_ebs_snapshot" "snap" {
  volume_id   = aws_ebs_volume.this.id
  description = "snapshot created by terraform"
  tags        = merge(var.tags, { Name = "tf-ebs-snapshot" })
}
