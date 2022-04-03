resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  tags          = var.tags
  force_destroy = var.force_destroy

  # dynamic "grant" {
  #   for_each = try(jsondecode(var.grants), var.grants)
  #   content {
  #     id          = lookup(grant.value, "id", null)
  #     type        = grant.value.type
  #     permissions = grant.value.permissions
  #     uri         = lookup(grant.value, "uri", null)
  #   }
  # }

  #dynamic logging {
  #  for_each = [var.log_bucket]
  #  content {
  #    target_bucket = var.log_bucket
  #    target_prefix = var.target_prefix
  #  }
  #}

  #server_side_encryption_configuration {
  #  rule {
  #    apply_server_side_encryption_by_default {
  #      kms_master_key_id = var.kms_master_key_id
  #      sse_algorithm     = var.sse_algorithm
  #    }
  #  }
  #}
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = length(var.grants) == 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_acl" "bucket_grants" {
  bucket = aws_s3_bucket.bucket.id

  access_control_policy {
    dynamic "grant" {
      for_each = try(jsondecode(var.grants), var.grants)
      content {
        grantee {
          id   = lookup(grant.value, "id", null)
          type = grant.value.type
        }
        permission = grant.value.permissions
      }
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.policy
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning
  }
}


resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
