output "deny_leave_org_policy_id" {
  value       = aws_organizations_policy.deny_leave_org.id
  description = "Policy ID for the Deny Leave Organization SCP"
}

output "region_restriction_policy_id" {
  value       = aws_organizations_policy.region_restriction.id
  description = "Policy ID for the Region Restriction SCP"
}

output "protect_security_services_policy_id" {
  value       = aws_organizations_policy.protect_security_services.id
  description = "Policy ID for the Protect Security Services SCP"
}

output "attached_target_ou_ids" {
  value       = var.target_ou_ids
  description = "List of OUs enforced by these Service Control Policies"
}