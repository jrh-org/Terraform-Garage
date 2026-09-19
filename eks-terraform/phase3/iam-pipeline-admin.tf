###############################################################################
# phase3/eks-access-pipeline-admin.tf
###############################################################################
# Grants aws_iam_role.pipeline_admin (phase3/iam-pipeline-admin.tf) access
# into the EKS cluster via the modern EKS Access Entry API (the cluster is
# already running authentication_mode = "API_AND_CONFIG_MAP", see
# phase1/modules/eks/main.tf, so no aws-auth ConfigMap edits are needed).

resource "aws_eks_access_entry" "pipeline_admin" {
  cluster_name  = local.cluster_name
  principal_arn = aws_iam_role.pipeline_admin.arn
  type          = "STANDARD"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

# AmazonEKSAdminPolicy, as requested. Note this is distinct from the
# AmazonEKSClusterAdminPolicy already used for module.codebuild's own role
# a few lines up: AmazonEKSAdminPolicy maps to Kubernetes' built-in "admin"
# ClusterRole (full read/write on almost everything in the given scope,
# including RBAC role/rolebinding management within that scope), while
# ClusterAdminPolicy maps to "cluster-admin" (true superuser, no
# restrictions at all). If you actually want full superuser here too,
# swap the policy_arn below for ".../AmazonEKSClusterAdminPolicy".
resource "aws_eks_access_policy_association" "pipeline_admin" {
  cluster_name  = local.cluster_name
  principal_arn = aws_iam_role.pipeline_admin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.pipeline_admin]
}
