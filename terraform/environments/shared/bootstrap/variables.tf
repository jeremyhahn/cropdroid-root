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

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  sso_domain                 = data.terraform_remote_state.root_bootstrap.outputs.sso_domain
  staging_account_id         = "841167668311"
  prod_account_id            = "640945925798"
  remotestate_bucket_name    = "terraform-remote-state-${local.account_id}"
  remotestate_dynamodb_table = "terraform-remote-state-locks"
}
