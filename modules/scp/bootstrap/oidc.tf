# 1. Register GitHub as an OpenID Connect (OIDC) Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]

  # Thumbprint for GitHub Actions OIDC provider
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Define Trust Policy allowing specific GitHub Repository & Branches
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict execution strictly to your repository and main branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:your-github-org/aws-landing-zone:ref:refs/heads/main"]
    }
  }
}

# 3. Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_tf_runner" {
  name               = "github-actions-terraform-runner"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}

# 4. Attach Policies Required for S3 State & Multi-Account Role Assumptions
data "aws_iam_policy_document" "github_actions_permissions" {
  # Permission to read/write Terraform state in S3 and lock in DynamoDB
  statement {
    sid    = "TerraformStateBackendAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resource = [
      "arn:aws:s3:::org-tfstate-landing-zone-management",
      "arn:aws:s3:::org-tfstate-landing-zone-management/*",
      "arn:aws:dynamodb:us-east-1:*:table/org-tfstate-locks-landing-zone"
    ]
  }

  # Permission to decrypt state file using KMS
  statement {
    sid    = "KMSKeyAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resource = "*"
  }

  # Permission to assume cross-account roles in target child accounts
  statement {
    sid      = "AssumeCrossAccountRoles"
    effect   = "Allow"
    actions  = ["sts:AssumeRole"]
    resource = "arn:aws:iam::*:role/OrganizationAccountAccessRole"
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-terraform-policy"
  description = "Permissions for GitHub Actions to run multi-account Terraform"
  policy      = data.aws_iam_policy_document.github_actions_permissions.json
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.github_actions_tf_runner.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_tf_runner.arn
  description = "ARN of the IAM Role to use in GitHub Actions workflow"
}