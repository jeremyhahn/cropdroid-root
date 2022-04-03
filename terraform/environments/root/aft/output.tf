
output "aft_vpc_cidr" {
  value = local.aft_vpc_cidr
}

output "aft_vpc_private_subnet_01_cidr" {
  value = local.aft_vpc_private_subnet_01_cidr
}

output "aft_vpc_private_subnet_02_cidr" {
  value = local.aft_vpc_private_subnet_02_cidr
}

output "aft_vpc_public_subnet_01_cidr" {
  value = local.aft_vpc_public_subnet_01_cidr
}

output "aft_vpc_public_subnet_02_cidr" {
  value = local.aft_vpc_public_subnet_02_cidr
}

output "aft_feature_delete_default_vpcs_enabled" {
  value = local.aft_feature_delete_default_vpcs_enabled
}
