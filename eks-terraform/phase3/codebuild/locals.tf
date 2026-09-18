###############################################################################
# phase3/codebuild/locals.tf
###############################################################################
resource "random_id" "suffix" {
  byte_length = 2  # 4 hex chars, e.g. "a1b2"
}

locals {
  is_org_scope = var.webhook_scope == "GITHUB_ORGANIZATION"

  github_repo_url = "https://github.com/${var.github_organization}/${var.github_repository}.git"

  # Org-wide runner projects must use this placeholder source location per
  # AWS docs (github-global-organization-webhook-setup) - the actual repo is
  # supplied dynamically by whichever repo's workflow queues the job.
  source_location = local.is_org_scope ? "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION" : local.github_repo_url

  project_description = local.is_org_scope ? "GitHub Actions self-hosted runner for all repos in ${var.github_organization}" : "GitHub Actions self-hosted runner for ${var.github_organization}/${var.github_repository}"

  # Appends "-<suffix>" only when deployment_suffix is set, so the default
  # behavior (no suffix) is unchanged from before.
  effective_suffix = var.deployment_suffix != "" ? var.deployment_suffix : random_id.suffix.hex
  name_prefix       = "${var.project_name}-${var.environment}-${local.effective_suffix}"
  
  ecr_registry = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
