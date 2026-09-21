variable "target_ou_ids" {
  type        = list(string)
  description = "List of Organizational Unit (OU) IDs where SCPs should be attached"
}

variable "allowed_regions" {
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
  description = "List of AWS regions permitted across member accounts"
}