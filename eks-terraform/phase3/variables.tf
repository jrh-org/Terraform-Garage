###############################################################################
# phase3/variables.tf
###############################################################################

variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name - must match the value used in Phase 1"
  type        = string
}

variable "environment" {
  description = "Environment label (sandbox, staging, production)"
  type        = string
  default     = "sandbox"
}

variable "deployment_suffix" {
  description = <<-EOT
    Optional suffix appended to the CodeBuild project name (e.g. "v2", "retry1").
    Bump this to sidestep a stale GitHub Actions webhook left over from a
    previous run/account without needing to delete it from GitHub first.
  EOT
  type        = string
  default     = ""
}

variable "github_organization" {
  description = "GitHub organization name or username (e.g. Books-POCGroups)"
  type        = string
}

variable "github_repository" {
  description = <<-EOT
    GitHub repository name without the org prefix. Only used (and required)
    when webhook_scope = "REPOSITORY". Leave as "" when webhook_scope =
    "GITHUB_ORGANIZATION".
  EOT
  type        = string
  default     = ""
}

variable "webhook_scope" {
  description = <<-EOT
    "REPOSITORY" (default) for a single-repo runner, or "GITHUB_ORGANIZATION"
    for one project that serves every repo in github_organization. See
    codebuild/variables.tf for the PAT scope this requires.
  EOT
  type        = string
  default     = "REPOSITORY"
}

variable "github_branch" {
  description = "Default branch of the repository"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub personal access token (scopes: repo, admin:repo_hook, workflow)"
  type        = string
  sensitive   = true
}

variable "build_timeout" {
  description = "Maximum build duration in minutes"
  type        = number
  default     = 60
}

variable "compute_type" {
  description = "CodeBuild compute type: BUILD_GENERAL1_SMALL, MEDIUM, LARGE, XLARGE"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "db_master_password" {
  description = <<-EOT
    Master password for the sandbox RDS PostgreSQL instance.
    Defaults to "postgres" as requested - fine for a throwaway sandbox DB
    that isn't publicly accessible, but change it (and rotate) before this
    is anything longer-lived, since it's a well-known/guessable default.
  EOT
  type        = string
  sensitive   = true
  default     = "postgres"
}

###############################################################################
# ADD TO phase3/outputs.tf
###############################################################################

output "rds_endpoint" {
  description = "RDS PostgreSQL connection endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "RDS PostgreSQL host address (no port) - use this for DNS/host env vars"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "rds_db_name" {
  description = "Default database name"
  value       = aws_db_instance.postgres.db_name
}

output "rds_sg_id" {
  description = "Security group ID attached to the RDS instance"
  value       = aws_security_group.postgres.id
}
