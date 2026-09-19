###############################################################################
# phase3/iam-pipeline-admin.tf
###############################################################################

resource "aws_iam_role" "pipeline_admin" {
  name        = "${var.project_name}-${var.environment}-pipeline-admin-role"
  description = "Admin-access role assumable by the CodeBuild pipeline role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCodeBuildRoleAssume"
        Effect    = "Allow"
        Principal = { AWS = module.codebuild.codebuild_role_arn }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

resource "aws_iam_role_policy_attachment" "pipeline_admin" {
  role       = aws_iam_role.pipeline_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
