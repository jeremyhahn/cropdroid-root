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

// Account Factory for Terraform (AFT)
// https://github.com/aws-ia/terraform-aws-control_tower_account_factory
locals {
  ct_management_account_id    = data.terraform_remote_state.root_bootstrap.outputs.ct_management_account_id
  log_archive_account_id      = data.terraform_remote_state.root_bootstrap.outputs.log_archive_account_id
  audit_account_id            = data.terraform_remote_state.root_bootstrap.outputs.audit_account_id
  aft_management_account_id   = data.terraform_remote_state.root_bootstrap.outputs.aft_management_account_id
  ct_home_region              = data.terraform_remote_state.root_bootstrap.outputs.ct_home_region
  tf_backend_secondary_region = data.terraform_remote_state.root_bootstrap.outputs.tf_backend_secondary_region

  aft_vpc_cidr = "10.0.0.0/16"
  aft_vpc_private_subnet_01_cidr = "10.0.10.0/24"
  aft_vpc_private_subnet_02_cidr = "10.0.11.0/24"
  aft_vpc_public_subnet_01_cidr = "10.0.20.0/24"
  aft_vpc_public_subnet_02_cidr = "10.0.21.0/24"

  aft_feature_delete_default_vpcs_enabled = true

  # account_customizations_repo_branch              = "main"
  # account_provisioning_customizations_repo_branch = "main"
  # account_request_repo_branch                     = "main"
  # global_customizations_repo_branch               = "main"
  # aft_feature_cloudtrail_data_events              = false
}
