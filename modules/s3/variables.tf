variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "enable_cloudfront" {
  type        = bool
  description = "Whether to enable CloudFront integration"
}

variable "cloudfront_access_policy" {
  type        = string
  description = "IAM policy document for CloudFront access to S3 bucket"
}

variable "bucket_acl" {
  type        = string
  description = "ACL for the S3 bucket"
}

variable "block_public_acls" {
  type        = bool
  description = "Whether to block public ACLs for the bucket"
}

variable "block_public_policy" {
  type        = bool
  description = "Whether to block public bucket policies"
}

variable "ignore_public_acls" {
  type        = bool
  description = "Whether to ignore public ACLs"
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether to restrict public buckets"
}