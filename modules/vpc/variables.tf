variable "project" {
  type        = string
  description = "TAG : Project name."
}

variable "environment" {
  type        = string
  description = "TAG : Deployment environment."
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones where subnets will be created."
  type        = list(string)
}
