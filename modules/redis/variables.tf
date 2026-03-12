variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Redis will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "redis_configuration" {
  type = object({
    node_type        = string
    port             = number
    parameter_group  = string
    engine_version   = string
  })
  description = "Configuration for Redis simple cluster"
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group ID of the ECS service"
}
