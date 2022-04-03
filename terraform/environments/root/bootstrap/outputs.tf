# Bootstrap module
output "organization_name" {
  value = local.organization_name
}

output "organization_id" {
  value = local.organization_id
}

output "ct_management_account_id" {
  value = local.ct_management_account_id
}

output "log_archive_account_id" {
  value = local.log_archive_account_id
}

output "audit_account_id" {
  value = local.audit_account_id
}

output "aft_management_account_id" {
  value = local.aft_management_account_id
}

output "ct_home_region" {
  value = local.ct_home_region
}

output "tf_backend_secondary_region" {
  value = local.tf_backend_secondary_region
}

output "sso_domain" {
  value = local.sso_domain
}

## tagging
output "tags" {
  value = module.tagging.tags
}

## Remote state
output "remote_state_bucket" {
    value = module.remotestate.bucket
}

output "remote_state_dynamo_table" {
    value = module.remotestate.dynamo_table
}
