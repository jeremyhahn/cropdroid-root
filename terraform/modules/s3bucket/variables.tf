variable "bucket_name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  default     = ""
}

variable "acl" {
  type        = string
  description = "(Optional) The canned ACL to apply. Defaults to private. Conflicts with grant."
  default     = "private"
}

variable "grants" {
  type        = any
  description = "(Optional) An ACL policy grant. Conflicts with acl."
  default     = []
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "versioning" {
  type        = string
  description = "(Optional) A state of versioning. [Enabled Suspended Disabled]"
  default     = "Disabled"
}

variable "log_bucket" {
  type        = string
  description = "(Required) The name of the bucket that will receive the log objects."
  default     = ""
}

variable "target_prefix" {
  type        = string
  description = "(Optional) To specify a key prefix for log objects."
  default     = "log/"
}

variable "kms_master_key_id" {
  type        = string
  description = "(optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = "aws/s3"
}

variable "sse_algorithm" {
  type        = string
  description = "(required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = {}
}

variable "force_destroy" {
  type        = bool
  description = "(Optional) True to automatically delete all items in the bucket when 'terraform destroy' is run"
  default     = false
}
