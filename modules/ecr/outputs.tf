output "ecr_arn" {
  value       = [for repo in aws_ecr_repository.ecr_repositories : repo.arn]
  description = "Returns a list of ARNs (Amazon Resource Names) for created ECR repositories"
}

output "ecr_url" {
  value = { for repo in aws_ecr_repository.ecr_repositories : repo.name => repo.repository_url }
  description = "Map of URLs for created ECR repositories"
}

output "repository_configs" {
  value = { for k, v in aws_ecr_repository.ecr_repositories : k => {
    arn  = v.arn
    url  = v.repository_url
    name = v.name
  }}
  description = "Detailed configuration of created ECR repositories"
}

