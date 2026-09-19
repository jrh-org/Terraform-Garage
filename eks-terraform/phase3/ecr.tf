###############################################################################
# phase3/ecr.tf
###############################################################################
# ECR repository for storing application images built by the CodeBuild
# GitHub Actions runner (module.codebuild already has ecr:PutImage /
# ecr:CreateRepository etc. via its IAM policy, scoped to
# arn:aws:ecr:<region>:<account>:repository/* — no IAM changes needed here).

resource "aws_ecr_repository" "books_ms_repo" {
  name                 = "books-ms-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

# Optional but recommended: expire untagged images after 14 days so failed/
# superseded pushes don't accumulate storage cost indefinitely. Tagged
# images (your real releases) are never touched by this rule.
resource "aws_ecr_lifecycle_policy" "books_ms_repo" {
  repository = aws_ecr_repository.books_ms_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
