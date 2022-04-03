// root bucket
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.root_bucket.id
  index_document {
    suffix = var.website_index_document
  }
  error_document {
    key = var.website_error_document
  }
}

resource "aws_s3_bucket_cors_configuration" "root_bucket" {
  bucket = aws_s3_bucket.root_bucket.id
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = [
      "http://www.${var.external_dns_name}",
      "http://${var.external_dns_name}",
      "https://www.${var.external_dns_name}",
      "https://${var.external_dns_name}"
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "root_bucket" {
  bucket = aws_s3_bucket.root_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "root_bucket" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = data.aws_iam_policy_document.root_bucket_policy.json
}

data "aws_iam_policy_document" "root_bucket_policy" {
  statement {
    sid = "AllReadOnly"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
  statement {
    sid = "AllowPipelineWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    principals {
      type = "AWS"
      identifiers = [var.pipeline_role_arn]
    }
  }
}

// www bucket
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.bucket_name}"
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.bucket
  redirect_all_requests_to {
    protocol  = local.redirect_protocol
    host_name = var.external_dns_name
  }
}

resource "aws_s3_bucket_acl" "www_bucket_acl" {
  bucket = aws_s3_bucket.www_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.www_bucket_policy.json
}

data "aws_iam_policy_document" "www_bucket_policy" {
  statement {
    sid = "Enable IAM User Permissions"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::www.${var.bucket_name}/*"
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}
