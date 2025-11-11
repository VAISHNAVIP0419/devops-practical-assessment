# EBS Volume ID - For attaching to EC2 instances
output "volume_id" {
  value       = aws_ebs_volume.this.id
  description = "EBS volume ID - used to attach volume to EC2 instance"
}

# EBS Snapshot ID - For backup and recovery reference
output "snapshot_id" {
  value       = aws_ebs_snapshot.snap.id
  description = "EBS snapshot ID - can be used to restore or create new volumes"
}
