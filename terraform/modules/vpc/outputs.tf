output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_cidr" {
  value = var.cidr
}

output "public_cidrs" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "internal_dns_name" {
  value = aws_route53_zone.internal.name
}

output "internal_dns_zone_id" {
  value = aws_route53_zone.internal.zone_id
}

output "external_dns_name" {
  value = var.enable_managed_external_zone ? data.aws_route53_zone.external_data[0].name : aws_route53_zone.external[0].name
}

output "external_dns_zone_id" {
  value = var.enable_managed_external_zone ? data.aws_route53_zone.external_data[0].zone_id : aws_route53_zone.external[0].zone_id
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}

output "bastion_keypair_name" {
  value = var.create_bastion_keypair ? module.bastion.keypair_name : ""
}

# Published to SSM to enhance security
#output "bastion_private_key_pem" {
#  value = var.create_bastion_keypair ? module.bastion.private_key_pem : ""
#}

output "bastion_public_key_pem" {
  value = var.create_bastion_keypair ? module.bastion.public_key_pem : ""
}

output "bastion_public_key_openssh" {
  value = var.create_bastion_keypair ? module.bastion.public_key_openssh : ""
}

output "bastion_ssm_private_key_pem_arn" {
  value = var.create_bastion_keypair ? module.bastion.ssm_private_key_pem_arn : ""
}

output "bastion_ssm_private_key_pem_name" {
  value = var.create_bastion_keypair ? module.bastion.ssm_private_key_pem_name : ""
}

output "s3_artifact_repo" {
  value = var.artifact_bucket_name
}

output "s3_log_bucket" {
  value = var.log_bucket_name
}

output "tags" {
  value = var.tags
}
