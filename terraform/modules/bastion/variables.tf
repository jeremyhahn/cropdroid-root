variable "env" {
  description = "Deployment environment"
  default     = "staging"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "asg_subnets" {
  type        = list(string)
  description = "The subnet ids to assign to the bastion auto scaling group"
}

variable "ami_id" {
  type        = string
  description = "EC2 image ID"
  default     = "ami-04d29b6f966df1537" # (64-bit x86) Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t2.micro"
}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair stored in EC2"
  default     = "bastion-staging"
}

variable "create_keypair" {
  type        = bool
  description = "True to create a terraform managed keypair, false to skip key creation and use an existing key"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "log_bucket" {
  type        = string
  description = "S3 bucket to send bastion host logs"
  default     = "logs-staging"
}

variable "iam_instance_profile" {
  type        = string
  description = "The instance iam profile to assign to the bastion node"
  default     = ""
}

variable "userdata" {
  type        = string
  description = "The instance user data"
  default     = null
}

variable "volume_size" {
  type        = string
  description = "The size (GB) of the root block device"
  default     = 8
}
