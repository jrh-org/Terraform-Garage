###############################################################################
# phase3/security-group-mapping.tf
###############################################################################
# Allows the CodeBuild runner's security group to reach the EKS cluster's
# control-plane security group on all ports/protocols. This is what lets
# CodeBuild (running inside the VPC - see codebuild/security_group.tf)
# reach the private EKS API endpoint to run kubectl/helm deploy steps.
#
# This is an aws_security_group_rule (not an inline block on the SG itself),
# so it's safe to manage from phase3's state even though the SG resource
# itself lives in phase1's state - it just adds one more rule alongside the
# ones phase1 already manages on that same SG (e.g. kubectl_to_cluster).

resource "aws_security_group_rule" "codebuild_to_cluster_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = local.cluster_sg_id
  source_security_group_id = module.codebuild.codebuild_sg_id
  description              = "CodeBuild runner - all traffic"

  depends_on = [module.codebuild]
}
