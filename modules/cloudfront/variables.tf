variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to use as origin"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the S3 bucket"
}

variable "price_class" {
  type        = string
  description = "Price class for CloudFront distribution"
}

variable "use_default_certificate" {
  type        = bool
  description = "Whether to use default CloudFront certificate"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of ACM certificate to use (if not using default)"
}

variable "default_root_object" {
  type        = string
  description = "Default root object for CloudFront distribution"
}

variable "min_ttl" {
  type        = number
  description = "Minimum TTL for cache behavior"
}

variable "default_ttl" {
  type        = number
  description = "Default TTL for cache behavior"
}

variable "max_ttl" {
  type        = number
  description = "Maximum TTL for cache behavior"
}

variable "compress" {
  type        = bool
  description = "Whether to compress objects for requests"
}

variable "ssl_support_method" {
  type        = string
  description = "SSL support method for viewer certificate"
}

variable "minimum_protocol_version" {
  type        = string
  description = "Minimum protocol version for SSL/TLS"
}

variable "aliases" {
  type        = list(string)
  description = "List of aliases (domain names) for CloudFront distribution"
}