
module "vpc" {
  source                     = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-vpc?ref=v0.0.1a"
  name                       = var.name
  env                        = var.env
  cidr                       = var.cidr
  azs                        = var.azs
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  database_subnets           = var.database_subnets
  intra_subnets              = var.intra_subnets
  enable_nat_gateway         = false
  single_nat_gateway         = true
  one_nat_gateway_per_az     = false
  internal_zone_name         = var.internal_zone_name
  external_zone_name         = var.external_zone_name
  create_log_bucket          = false
  create_artifact_repo       = true
  artifact_bucket_acl        = null
  artifact_bucket_name       = local.bucket_name
  artifact_bucket_grants     = local.bucket_grants
  artifact_bucket_policy     = data.aws_iam_policy_document.bucket_policy.json
  artifact_bucket_versioning = "Enabled"
  bastion_keypair_name       = var.bastion_keypair_name
  create_bastion_keypair     = var.create_bastion_keypair
  create_bastion_host        = false
  tags                       = data.terraform_remote_state.shared_services.outputs.tags
}

// Create bucket policy for shared artifact repo
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = local.bucket_policy_principals
    }
    actions = [
      "s3:ListBucket",
      "s3:Get*"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}"
    ]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = local.bucket_policy_principals
    }
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*.zip"
    ]
  }
}
