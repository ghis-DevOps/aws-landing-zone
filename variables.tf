variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary AWS deployment region"
}

variable "allowed_regions" {
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
  description = "List of approved AWS regions enforced by SCP"
}

variable "root_email" {
  type        = string
  description = "Email address for the management account"
}

variable "log_archive_email" {
  type        = string
  description = "Email address for the Log Archive account"
}

variable "security_tooling_email" {
  type        = string
  description = "Email address for the Security Tooling account"
}

variable "shared_services_email" {
  type        = string
  description = "Email address for the Shared Services account"
}

variable "prod_workload_email" {
  type        = string
  description = "Email address for the Production Workload account"
}

variable "dev_workload_email" {
  type        = string
  description = "Email address for the Development Workload account"
}