###############################################################################
# phase3/dns-postgres.tf
###############################################################################
# Private Route53 zone, resolvable only inside the VPC (EKS pods use the
# VPC's default DNS resolver, so this works automatically - no extra config
# needed in pods/CoreDNS). Gives Spring Boot a fixed hostname that keeps
# working even if the underlying RDS endpoint changes on recreate.

resource "aws_route53_zone" "internal" {
  name = "${var.project_name}.internal"

  vpc {
    vpc_id = local.vpc_id
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

resource "aws_route53_record" "postgres" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "postgres.${var.project_name}.internal"
  type    = "CNAME"
  ttl     = 60
  records = [aws_db_instance.postgres.address]
}