resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${lower(var.project)}-${lower(var.environment)}-rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.rds_configuration.master_username
    password = random_password.master_password.result
    engine   = "postgres"
    host     = aws_rds_cluster.aurora.endpoint
    port     = var.rds_configuration.db_port
    dbname   = var.rds_configuration.database_name
  })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${lower(var.project)}-${lower(var.environment)}-aurora"
  engine                  = var.rds_configuration.engine
  engine_version          = var.rds_configuration.engine_version
  database_name           = var.rds_configuration.database_name
  master_username         = var.rds_configuration.master_username
  master_password         = random_password.master_password.result
  backup_retention_period = var.rds_configuration.backup_retention_period
  preferred_backup_window = var.rds_configuration.preferred_backup_window
  preferred_maintenance_window = var.rds_configuration.preferred_maintenance_window
  storage_encrypted       = var.rds_configuration.storage_encrypted
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${lower(var.project)}-${lower(var.environment)}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.rds_configuration.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}

resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${lower(var.project)}-${lower(var.environment)}-aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.rds_configuration.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  promotion_tier     = 15
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${lower(var.project)}-${lower(var.environment)}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "rds" {
  name        = "${lower(var.project)}-${lower(var.environment)}-rds-sg"
  description = "Security group for RDS Aurora"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.rds_configuration.db_port
    to_port     = var.rds_configuration.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}