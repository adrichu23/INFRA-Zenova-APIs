# Redis replication group with AUTH token
# Managed by Terraform — includes auth_token and Secrets Manager credentials

# --- Auth token generation ---
resource "random_password" "redis_auth_token" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  # ElastiCache auth_token prohibits: / " @ and spaces
}

# --- Secrets Manager for Redis credentials ---
resource "aws_secretsmanager_secret" "redis_credentials" {
  name                    = "${lower(var.project)}-${lower(var.environment)}-redis-credentials"
  description             = "Redis credentials for ${var.project} ${var.environment}"
  recovery_window_in_days = 0 # Allow immediate deletion in dev
}

resource "aws_secretsmanager_secret_version" "redis_credentials" {
  secret_id = aws_secretsmanager_secret.redis_credentials.id
  secret_string = jsonencode({
    host     = aws_elasticache_replication_group.redis.primary_endpoint_address
    port     = var.redis_configuration.port
    password = random_password.redis_auth_token.result
  })
}

# --- Networking ---
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${lower(var.project)}-${lower(var.environment)}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "${lower(var.project)}-${lower(var.environment)}-redis-sg"
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.redis_configuration.port
    to_port         = var.redis_configuration.port
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ElastiCache Replication Group ---
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${lower(var.project)}-${lower(var.environment)}-redis"
  description          = "Redis cluster for ${var.project} ${var.environment}"
  node_type            = var.redis_configuration.node_type
  num_cache_clusters   = 1
  parameter_group_name = var.redis_configuration.parameter_group
  engine_version       = var.redis_configuration.engine_version
  port                 = var.redis_configuration.port
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  automatic_failover_enabled = false
  auth_token                 = random_password.redis_auth_token.result
  auth_token_update_strategy = "ROTATE"
}
