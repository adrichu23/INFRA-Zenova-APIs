output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app_distribution.id
}

output "domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app_distribution.domain_name
}

output "hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app_distribution.hosted_zone_id
}

output "cloudfront_access_policy" {
  description = "IAM policy document for CloudFront access to S3"
  value       = data.aws_iam_policy_document.cloudfront_access.json
}