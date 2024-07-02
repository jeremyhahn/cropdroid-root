module "aft" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory"

  ct_management_account_id    = local.ct_management_account_id
  log_archive_account_id      = local.log_archive_account_id
  audit_account_id            = local.audit_account_id
  aft_management_account_id   = local.aft_management_account_id
  ct_home_region              = local.ct_home_region
  tf_backend_secondary_region = local.tf_backend_secondary_region

  # account_customizations_repo_branch              = local.account_customizations_repo_branch
  # account_provisioning_customizations_repo_branch = local.account_provisioning_customizations_repo_branch
  # account_request_repo_branch                     = local.account_request_repo_branch
  # global_customizations_repo_branch               = local.global_customizations_repo_branch

  aft_vpc_cidr                   = local.aft_vpc_cidr
  aft_vpc_private_subnet_01_cidr = local.aft_vpc_private_subnet_01_cidr
  aft_vpc_private_subnet_02_cidr = local.aft_vpc_private_subnet_02_cidr
  aft_vpc_public_subnet_01_cidr  = local.aft_vpc_public_subnet_01_cidr
  aft_vpc_public_subnet_02_cidr  = local.aft_vpc_public_subnet_02_cidr

  aft_feature_delete_default_vpcs_enabled = local.aft_feature_delete_default_vpcs_enabled
  # aft_feature_cloudtrail_data_events      = local.aft_feature_cloudtrail_data_events
}
