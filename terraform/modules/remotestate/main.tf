
resource "aws_s3_bucket" "remotestate" {
  count         = var.create_lock_table_only ? 0 : 1
  bucket        = var.s3_bucket_name
  # acl           = "private"
  force_destroy = true
  tags          = var.tags

  # versioning {
  #   enabled = true
  # }

  # dynamic "grant" {
  #   for_each = var.read_only_grants
  #   content {
  #     id          = var.read_only_grants[count.index]
  #     type        = "CanonicalUser"
  #     permissions = ["READ"]
  #   }
  # }

  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = var.create_lock_table_only ? 0 : 1

  bucket = aws_s3_bucket.remotestate[0].id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "remotestate" {
  name = var.aws_dynamodb_table
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}
