resource "aws_ecr_repository" "ecr_repositories" {
  for_each = var.infra_configuration

  name = "${lower(var.project)}-${lower(var.environment)}-${lower(each.value.name)}"

  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
