variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "shared"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "onelinkjs-shared"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}
