output "keypair_name" {
  value = var.keypair_name
}

# Instead of outputting the private key, use `jq` to extract it from the state file:
# terraform state pull | jq -r '.resources[] | select(.type == "tls_private_key") | .instances[0].attributes.private_key_pem'
#output "private_key_pem" {
#  value = var.create_keypair ? tls_private_key.bastion[0].private_key_pem : ""
#}

output "public_key_pem" {
  value = var.create_keypair ? tls_private_key.bastion[0].public_key_pem : ""
}

output "public_key_openssh" {
  value = var.create_keypair ? tls_private_key.bastion[0].public_key_openssh : ""
}

output "ssm_private_key_pem_arn" {
  value = var.create_keypair ? aws_ssm_parameter.bastion_private_key_pem[0].arn : ""
}

output "ssm_private_key_pem_name" {
  value = var.create_keypair ? aws_ssm_parameter.bastion_private_key_pem[0].name : ""
}

output "security_group_id" {
  value = aws_security_group.bastion.id
}

output "launch_configuration_id" {
  value = aws_launch_configuration.bastion.id
}

output "launch_configuration_arn" {
  value = aws_launch_configuration.bastion.arn
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.bastion.id
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.bastion.arn
}
