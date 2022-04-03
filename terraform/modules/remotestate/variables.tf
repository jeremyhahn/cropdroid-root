variable "region" {
    default = "us-east-1"
}

variable "env" {
  type        = string
  description = "Environment: staging, rc or prod"
}

variable "name" {
  type        = string
  description = "Terraform module name storing the remote state"
}

variable "s3_bucket_name" {
  default = "terraform-remote-state"
}

variable "aws_dynamodb_table" {
  default = "terraform-remote-state-lock"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "create_lock_table_only" {
  type        = bool
  description = "True to only create the dynamodb locking table, false to create both s3 bucket and dynamodb table"
  default     = false
}

# variable "read_only_grants" {
#   type        = list(string)
#   description = "A list of canonical user ids who are allowed to read the bucket contents"
#   default     = []
# }
