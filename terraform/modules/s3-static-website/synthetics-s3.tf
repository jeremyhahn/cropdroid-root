data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "canaries" {
  count = var.enable_synthetics ? 1 : 0

  bucket        = "${var.bucket_name}-canaries"
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "canaries_policy" {
  count  = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.canaries[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id = "CanariesPolicy"
    Statement = [
      {
        Sid = "Permissions"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = ["s3:*"]
        Resource = ["${aws_s3_bucket.canaries[0].arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "canary_bucket_acl" {
  count = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.canaries[0].id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "canaries_versioning" {
  count = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.canaries[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning_bucket_config" {
  count = var.enable_synthetics ? 1 : 0

  depends_on = [aws_s3_bucket_versioning.canaries_versioning[0]]

  bucket = aws_s3_bucket.canaries[0].bucket
  rule {
    id     = "config"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 60
    }
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    #  storage_class   = "STANDARD_IA"
    }
  }
}
