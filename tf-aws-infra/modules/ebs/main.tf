# EBS VOLUME CREATION

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone    # Must be in same AZ as EC2 instance
  size              = var.size_gb              # Volume size in GB (default: 8)
  tags              = merge(var.tags, { Name = "tf-ebs-volume" })
}

# EBS SNAPSHOT

resource "aws_ebs_snapshot" "snap" {
  volume_id   = aws_ebs_volume.this.id         # Snapshot source volume
  description = "snapshot created by terraform"
  tags        = merge(var.tags, { Name = "tf-ebs-snapshot" })
}
