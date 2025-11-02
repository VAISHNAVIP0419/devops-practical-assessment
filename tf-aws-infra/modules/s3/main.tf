# create suffix if name not provided
resource "random_id" "suffix" {
  count       = var.bucket_name == "" ? 1 : 0
  byte_length = 4
}

locals {
  bucket_name_final = var.bucket_name != "" ? var.bucket_name : "${var.bucket_prefix}-${random_id.suffix[0].hex}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name_final
  force_destroy = var.force_destroy

  tags = merge(var.tags, { Name = local.bucket_name_final })
}

resource "aws_s3_bucket_versioning" "ver" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
