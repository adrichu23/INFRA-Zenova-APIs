#===================General===================#
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "project" {
  type        = string
  description = "TAG : Project name."
}

variable "environment" {
  type        = string
  description = "TAG : Deployment environment."
}

variable "s3_bucket" {
  type        = string
  description = "Nombre del contenedor S3"
}

variable "aws_account" {
  type        = string
  description = "AWS Account ID"
}

variable "owner" {
  type        = string
  description = "TAG: Project owner"
}

variable "createdby" {
  type        = string
  description = "TAG: Created by identifier"
}

#===================Tags===================#
variable "xal_environment" {
  type        = string
  description = "TAG: Environment classification (PoC/Prod/Dev)"
}

variable "xal_project" {
  type        = string
  description = "TAG: Project name description"
}

variable "xal_owner" {
  type        = string
  description = "TAG: Project owner email"
}

variable "xd_project_id" {
  type        = string
  description = "TAG: Project ID in XalDigital system"
}

variable "xd_backup_schedule" {
  type        = string
  description = "TAG: Backup schedule configuration"
}

#===================VPC===================#
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones where subnets will be created."
  type        = list(string)
}

#===================ECR===================#
variable "infra_configuration" {
  description = "Configuration map for ECR repositories and services"
  type        = map(any)
}

#===================RDS===================#
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

#===================Redis===================#
variable "redis_configuration" {
  type = object({
    node_type        = string
    port             = number
    parameter_group  = string
    engine_version   = string
  })
  description = "Configuration for Redis simple cluster"
}


variable "db_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for middleware DB"
}

variable "frontend_db_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for frontend DB"
}

#===================S3/CloudFront===================#
variable "enable_cloudfront" {
  type        = bool
  description = "Whether to enable CloudFront distribution"
}

variable "cloudfront_use_default_certificate" {
  type        = bool
  description = "Whether to use default CloudFront certificate"
}

variable "cloudfront_certificate_arn" {
  type        = string
  description = "ARN of ACM certificate for CloudFront"
}

variable "cloudfront_price_class" {
  type        = string
  description = "Price class for CloudFront distribution (PriceClass_100, PriceClass_200, PriceClass_All)"
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "Valid values for cloudfront_price_class are PriceClass_100, PriceClass_200, or PriceClass_All"
  }
}

variable "cloudfront_aliases" {
  type        = list(string)
  description = "List of domain aliases for CloudFront distribution"
  default     = []
}

variable "bucket_acl" {
  type        = string
  description = "ACL configuration for S3 bucket (private, public-read, etc)"
}

variable "block_public_acls" {
  type        = bool
  description = "Whether to block public ACLs for S3 bucket"
}

variable "block_public_policy" {
  type        = bool
  description = "Whether to block public bucket policies for S3 bucket"
}

variable "ignore_public_acls" {
  type        = bool
  description = "Whether to ignore public ACLs for S3 bucket"
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether to restrict public bucket policies for S3 bucket"
}

variable "default_root_object" {
  type        = string
  description = "Default root object for CloudFront distribution"
}

variable "min_ttl" {
  type        = number
  description = "Minimum TTL for CloudFront cache behavior"
}

variable "default_ttl" {
  type        = number
  description = "Default TTL for CloudFront cache behavior"
}

variable "max_ttl" {
  type        = number
  description = "Maximum TTL for CloudFront cache behavior"
}

variable "compress" {
  type        = bool
  description = "Whether to enable compression for CloudFront"
}

variable "ssl_support_method" {
  type        = string
  description = "SSL support method for CloudFront (sni-only or vip)"
}

variable "minimum_protocol_version" {
  type        = string
  description = "Minimum SSL/TLS protocol version for CloudFront"
}

