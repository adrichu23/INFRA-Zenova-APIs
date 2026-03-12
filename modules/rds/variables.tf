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
  description = "VPC ID where RDS will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "rds_configuration" {
  type = object({
    database_name                = string
    master_username              = string
    backup_retention_period      = number
    preferred_backup_window      = string
    preferred_maintenance_window = string
    storage_encrypted            = bool
    db_port                     = number
    engine                      = string
    engine_version              = string
    instance_class              = string
  })
  description = "Configuration for RDS Aurora PostgreSQL"
}
