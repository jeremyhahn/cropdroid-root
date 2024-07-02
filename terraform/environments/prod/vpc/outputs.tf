output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_cidrs" {
  value = module.vpc.public_cidrs
}

output "private_cidrs" {
  value = module.vpc.private_cidrs
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "internal_dns_name" {
  value = module.vpc.internal_dns_name
}

output "internal_dns_zone_id" {
  value = module.vpc.internal_dns_zone_id
}

output "external_dns_name" {
  value = module.vpc.external_dns_name
}

output "external_dns_zone_id" {
  value = module.vpc.external_dns_zone_id
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}

output "s3_artifact_repo" {
  value = module.vpc.s3_artifact_repo
}

output "s3_log_bucket" {
  value = module.vpc.s3_log_bucket
}

output "tags" {
  value = module.vpc.tags
}

# output "transit_gateway_attachment_id" {
#   value = aws_ec2_transit_gateway_vpc_attachment.prod.id
# }
