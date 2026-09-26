###############################################################################
# phase3/rds.tf
###############################################################################
# Sandbox PostgreSQL RDS instance for the microservice(s) running on EKS.
# - Lives in the same 3 private ("application") subnets as the EKS nodes,
#   one per AZ, via a DB subnet group.
# - Not publicly accessible; only reachable from inside those subnets.
# - Password auth, db.t4g.micro, single-AZ (sandbox = no HA, keeps cost/
#   complexity down - flip multi_az to true later if this becomes long-lived).

# Fetch the CIDR of each private/application subnet so the RDS security
# group can allow them by CIDR, without needing a new phase1 output.
data "aws_subnet" "private" {
  for_each = toset(local.private_subnet_ids)
  id       = each.value
}

# --- DB Subnet Group (spans all 3 AZs) --------------------------------------
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.project_name}-${var.environment}-postgres-subnet-group"
  subnet_ids = local.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

# --- Security Group -----------------------------------------------------
resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-${var.environment}-postgres-sg"
  description = "RDS PostgreSQL - sandbox"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}

# Full traffic (all ports/protocols) open to the application subnets, as
# requested - not just port 5432. Scope this down to tcp/5432 later if you
# want to tighten it once things are stable.
resource "aws_security_group_rule" "postgres_from_app_subnets" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.postgres.id
  cidr_blocks       = [for s in data.aws_subnet.private : s.cidr_block]
  description       = "All traffic from application (private/EKS) subnets"
}

# --- RDS Instance -------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = "postgres"
  password = var.db_master_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "3"
  }
}
