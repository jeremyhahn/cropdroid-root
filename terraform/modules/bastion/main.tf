
resource "aws_security_group" "bastion" {
  name   = "bastion-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "bastion" {
  count     = var.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "bastion_private_key_pem" {
  count       = var.create_keypair ? 1 : 0
  name        = "/bastion/keypair/private_key_pem"
  description = "Bastion EC2 instance private key"
  type        = "SecureString"
  value       = tls_private_key.bastion[0].private_key_pem
  tags        = var.tags
}

resource "aws_key_pair" "generated_key" {
  count      = var.create_keypair ? 1 : 0
  key_name   = var.keypair_name
  public_key = tls_private_key.bastion[count.index].public_key_openssh
}

resource "aws_launch_configuration" "bastion" {
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.bastion.id]
  key_name                    = var.create_keypair ? aws_key_pair.generated_key[0].key_name : var.keypair_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true
  user_data                   = var.userdata
  root_block_device {
    volume_size               = var.volume_size
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "bastion-${var.env}"
  launch_configuration = aws_launch_configuration.bastion.id
  vpc_zone_identifier  = var.asg_subnets
  min_size = 1
  max_size = 1
}
