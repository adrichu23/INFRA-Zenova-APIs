output "task_definition_arns" {
  description = "ARNs de las task definitions"
  value = {
    for k, v in aws_ecs_task_definition.task_definitions : k => v.arn
  }
}

output "cluster_name" {
  description = "Nombre del cluster ECS"
  value = { for k, v in aws_ecs_cluster.ecs_cluster : k => v.name }
}

output "cluster_arn" {
  description = "ARN del cluster ECS"
  value = { for k, v in aws_ecs_cluster.ecs_cluster : k => v.arn }
}

output "ecs_security_group_id" {
  description = "Security group ID of the ECS service"
  value       = aws_security_group.ecs_service.id
}
