output "cluster_endpoint" {
  description = "Endpoint del cluster Aurora"
  value       = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  description = "Endpoint de lectura del cluster Aurora"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "secret_arn" {
  description = "ARN del secreto en Secrets Manager"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "cluster_identifier" {
  description = "Identificador del cluster Aurora"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

output "security_group_id" {
  description = "ID del grupo de seguridad RDS"
  value       = aws_security_group.rds.id
}

output "secret_name" {
  description = "Nombre del secreto en Secrets Manager"
  value       = aws_secretsmanager_secret.rds_credentials.name
}