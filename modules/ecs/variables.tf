variable "project" {
  type        = string
  description = "TAG: Project name."
}

variable "infra_configuration" {
  type = map(object({
    name = string
    clusters = list(string)
    tasks = map(object({
      name                      = string
      network_mode              = string
      requires_compatibilities  = list(string)
      cpu                       = string
      memory                    = string
      container_definitions_path = string
      image_tag                 = string
      desired_count             = number
      log_stream_prefix         = string
    }))
  }))
  description = "Consolidated infrastructure configuration for ECS"
}

variable "environment" {
  type        = string
  description = "TAG: Deployment environment."
}

variable "region" {
  type        = string
  description = "Infrastructure deployment region."
}

variable "ecr_urls" {
  type        = map(string)
  description = "Map of ECR repository URLs"
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los recursos (grupos de seguridad y namespaces de CloudMap)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de subredes privadas"
  type        = list(string)
}

variable "container_ports" {
  type        = map(number)
  description = "Mapa de puertos de contenedores por servicio para el balanceador de carga"
}

variable "alb_target_group_arns" {
  type        = map(string)
  description = "Mapa de ARNs de target groups del ALB por servicio"
}

#variable "rds_secret_name" {
#  type        = string
#  description = "Nombre del secret manager que contiene las credenciales RDS"
#}

variable "s3_bucket" {
  type        = string
  description = "Nombre del contenedor S3"
}

variable "redis_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for Redis credentials"
}

variable "db_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for middleware DB"
}

variable "frontend_db_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for frontend DB"
}

