data "aws_caller_identity" "default" {}
data "aws_region" "default" {}

resource "aws_s3_bucket_object" "folder" {
    bucket = var.artifact_bucket
    acl    = "private"
    key    = "${var.repository_name}-${var.env}/"
    source = "/dev/null"
    server_side_encryption = "aws:kms"
}
