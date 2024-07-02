locals {
  tags = {
    Name             = var.name
    Project          = var.project
    Environment      = var.environment
    Owner            = var.owner
    Compliance       = var.compliance
    TerraformManaged = true
  }
}

output "tags" {
  description = "Mapping of tags for common AWS resources"
  value       = local.tags
}

data "null_data_source" "tags" {
  count = length(keys(local.tags))
  inputs = {
    key                 = element(keys(local.tags), count.index)
    value               = lookup(local.tags, element(keys(local.tags), count.index), "")
    propagate_at_launch = true
  }
}

output "tags_as_list" {
  description = "Used for things that need it in format of [{key=... value=... propagate_at_launch=...},{...}]"
  value       = data.null_data_source.tags.*.outputs
}
