# ===============================================
# S3 MODULE - MAIN CONFIGURATION
# ===============================================
# This module creates an S3 bucket with optional versioning
# S3 is used for storing Terraform state and application data

# ============================================================
# RANDOM SUFFIX GENERATION
# ============================================================
# Generates a random suffix for bucket name uniqueness
# S3 bucket names must be globally unique across all AWS accounts
# Conditional: only creates if var.bucket_name is not provided
resource "random_id" "suffix" {
  count       = var.bucket_name == "" ? 1 : 0  # Create only if bucket_name not specified
  byte_length = 4                               # 4 bytes = 8 hex characters
}

# ============================================================
# BUCKET NAME DETERMINATION
# ============================================================
# Uses provided bucket name or generates one with random suffix
# Example:
#   - If bucket_name = "my-bucket" → uses "my-bucket"
#   - If bucket_name = "" → creates "tf-assessment-state-a1b2c3d4"
locals {
  bucket_name_final = var.bucket_name != "" ? var.bucket_name : "${var.bucket_prefix}-${random_id.suffix[0].hex}"
}

# ============================================================
# S3 BUCKET CREATION
# ============================================================
# Creates the S3 bucket for storing Terraform state and data
resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name_final    # Final bucket name (user-provided or auto-generated)
  force_destroy = var.force_destroy          # Allow destruction even if bucket contains objects

  tags = merge(var.tags, { Name = local.bucket_name_final })
}

# S3 BUCKET VERSIONING

# Conditional: only enables if var.versioning = true
resource "aws_s3_bucket_versioning" "ver" {
  count  = var.versioning ? 1 : 0             # Create only if versioning enabled
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"  # Enable versioning on this bucket
  }
}
