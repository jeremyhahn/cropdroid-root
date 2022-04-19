
variable "name" {
  type        = string
  description = "The VPC name"
  default     = "cropdroid-shared"
}

variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "shared"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "cropdroid-shared"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cidr" {
  type        = string
  description = "The network cidr for the vpc"
  default     = "10.1.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones for the vpc"
  default     = ["us-east-1a", "us-east-1c", "us-east-1e"]
}

variable "public_subnets" {
  type        = list(string)
  description = "The vpc public subnets"
  default     = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "The vpc private subnets"
  default     = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "The vpc database subnets"
  default     = ["10.1.30.0/24", "10.1.31.0/24", "10.1.32.0/24"]
}

variable "intra_subnets" {
  type        = list(string)
  description = "The vpc intra (host only) subnets"
  default     = ["10.1.40.0/24", "10.1.41.0/24", "10.1.42.0/24"]
}

variable "internal_zone_name" {
  type        = string
  description = "Internal route53 zone name for the vpc"
  default     = "cropdroid-shared.internal"
}

variable "external_zone_name" {
  type        = string
  description = "External route53 zone name for the vpc"
  default     = "shared.cropdroid.com"
}

variable "tags" {
  type        = map
  description = "Tags to assign to the vpc resources"
  default     = {}
}

variable "log_bucket" {
  type        = string
  description = "S3 bucket to house logs for the vpc"
  default     = "cropdroid-logs"
}

variable "create_bastion_host" {
  type        = bool
  description = "True to create a terraform managed bastion host"
  default     = false
}

variable "bastion_keypair_name" {
  type        = string
  description = "The name of the keypair stored in EC2"
  default     = "bastion-shared"
}

variable "create_bastion_keypair" {
  type        = bool
  description = "True to create a terraform managed keypair, false to skip key creation and use an existing key"
  default     = false
}

locals {

  shared_canonical_id = data.aws_canonical_user_id.current.id
  shared_account_id   = data.aws_caller_identity.default.account_id

  stage_canonical_id  =  data.terraform_remote_state.stage_bootstrap.outputs.canonical_id
  stage_account_id    = data.terraform_remote_state.stage_bootstrap.outputs.account_id

  prod_canonical_id  =  data.terraform_remote_state.prod_bootstrap.outputs.canonical_id
  prod_account_id    = data.terraform_remote_state.prod_bootstrap.outputs.account_id

  bucket_name   = "cropdroid-artifacts-shared"
  bucket_grants = [{
    type        = "CanonicalUser"
    permissions = "FULL_CONTROL"
    id          = local.shared_canonical_id
  }, {
    type        = "CanonicalUser"
    permissions = "FULL_CONTROL"
    id          = local.stage_canonical_id
  }, {
    type        = "CanonicalUser"
    permissions = "FULL_CONTROL"
    id          = local.prod_canonical_id
  }]
  bucket_policy_principals = [
    local.shared_account_id,
    local.stage_account_id,
    local.prod_account_id
  ]
}
