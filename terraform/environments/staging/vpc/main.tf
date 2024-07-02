
module "vpc" {
  #source                      = "../../../modules/vpc"
  source                       = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-vpc?ref=v0.0.1a"
  name                         = var.name
  env                          = var.env
  cidr                         = var.cidr
  azs                          = var.azs
  public_subnets               = var.public_subnets
  private_subnets              = var.private_subnets
  database_subnets             = var.database_subnets
  intra_subnets                = var.intra_subnets
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
  internal_zone_name           = var.internal_zone_name
  external_zone_name           = var.external_zone_name
  // cropdroid-stage.com was purchased using route53 which
  // automatically creates the hosted zone after registration.
  //enable_managed_external_zone = true
  create_log_bucket            = false
  create_artifact_repo         = false
  create_bastion_host          = false
  create_bastion_keypair       = var.create_bastion_keypair
  # bastion_keypair_name         = var.bastion_keypair_name
  # bastion_iam_instance_profile = aws_iam_instance_profile.bastion.name
  # bastion_volume_size          = 60
  # bastion_userdata             = <<-EOF
  #   #!/bin/bash
  #   yum update -y
  #   yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
  #   yum install -y mysql-community-client docker
  #   echo "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.terraform_remote_state.shared_bootstrap.outputs.shared_account_id}.dkr.ecr.${var.region}.amazonaws.com" > /home/ec2-user/ecr_login.sh
  #   chmod +x /home/ec2-user/ecr_login.sh
  #   chown ec2-user.root /home/ec2-user/ecr_login.sh
  #   chmod +x /home/ec2-user/docker_xapis.sh
  #   usermod -a -G docker ec2-user
  #   systemctl start docker
  #   systemctl enable docker
  #   /home/ec2-user/ecr_login.sh
  #   #curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
  #   #chmod +x ./awslogs-agent-setup.py
  #   #./awslogs-agent-setup.py -n -r us-east-1 -c s3://${var.log_bucket}/bastion-${var.env}
  #   EOF
  tags = data.terraform_remote_state.staging_bootstrap.outputs.tags
}
