variable "project" {
  type        = string
  description = "TAG: Project name"
}

variable "environment" {
  type        = string
  description = "TAG: Deployment environment"
}

variable "infra_configuration" {
  description = "Configuration map for ECR repositories and services"
  type        = map(any)
}
