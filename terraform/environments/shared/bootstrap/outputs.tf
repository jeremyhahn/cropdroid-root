output "canonical_id" {
  value = data.aws_canonical_user_id.current.id
}

output "account_id" {
  value = local.account_id
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

# output "devops_role" {
#   value = aws_iam_role.devops.arn
# }
