variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "mgmt"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "cropdroid-mgmt"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

// Globals
locals {
  env     = var.env
  profile = var.profile
  region  = var.region
  organization_name = "cropdroid"
  organization_id   = "o-1mmfz07mip"
}

// Account Factory for Terraform (AFT)
locals {
  ct_management_account_id    = "288834285707"
  log_archive_account_id      = "695529858312"
  audit_account_id            = "695357733671"
  aft_management_account_id   = "685454867570"
  ct_home_region              = "us-east-1"
  tf_backend_secondary_region = "us-west-2"
  sso_domain                  = "cropdroid.com"
}

# // VPC
# locals {
#   vpc_cidr = "10.0.0.0/16"
#   vpc_internal_zone_name = "${local.env}.cropdroid.internal"
#   vpc_external_zone_name = "${local.env}.cropdroid.com"
#
#   vpc_azs = [
#     "us-east-1a",
#     "us-east-1c",
#     "us-east-1e"
#   ]
#
#   vpc_public_subnets = [
#     "10.0.0.0/24",
#     "10.0.1.0/24",
#     "10.0.2.0/24",
#   ]
#
#   vpc_private_subnets = [
#     "10.0.10.0/24",
#     "10.0.11.0/24",
#     "10.0.12.0/24",
#   ]
#
# }

// Remote state
locals {
  remotestate_bucket_name    = "cropdroid-terraform-remote-state-mgmt"
  remotestate_dynamodb_table = "cropdroid-terraform-remote-state-locks"
}
