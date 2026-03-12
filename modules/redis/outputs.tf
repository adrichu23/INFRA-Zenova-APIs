output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
  description = "Redis primary endpoint"
}

output "redis_port" {
  value = var.redis_configuration.port
  description = "Redis cluster port"
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
  description = "Security group ID for Redis"
}

output "redis_secret_name" {
  value       = aws_secretsmanager_secret.redis_credentials.name
  description = "Name of the Secrets Manager secret for Redis credentials"
}
