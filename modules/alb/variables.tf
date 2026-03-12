variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_configurations" {
  type = map(object({
    port            = number
    internal        = bool
    health_path     = string
    container_port  = number
    certificate_arn = string
  }))
}