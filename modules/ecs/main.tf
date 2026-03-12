resource "aws_cloudwatch_log_group" "ecs_logs" {
  for_each = merge([for service in local.services_config:
    service.tasks
  ]...)

  name              = "/ecs/${lower(var.project)}-${lower(var.environment)}-${each.value.name}"
  retention_in_days = 30
}

locals {
  services_config = [for service in values(var.infra_configuration): {
    clusters = service.clusters
    tasks    = service.tasks
  }]
}

resource "aws_ecs_cluster" "ecs_cluster" {
  for_each = { for service_key, service in var.infra_configuration:
    service_key => service.clusters[0]
  }
  name = "${lower(var.project)}-${lower(var.environment)}-${each.value}"
}

resource "aws_ecs_task_definition" "task_definitions" {
  for_each = merge([for service in local.services_config:
    service.tasks
  ]...)

  family                   = "${lower(var.project)}-${lower(var.environment)}-${each.value.name}"
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                      = each.value.cpu
  memory                   = each.value.memory

  container_definitions = templatefile(each.value.container_definitions_path, {
    var_task_name                = "${lower(var.project)}-${lower(var.environment)}-${each.value.name}"
    var_image_repo_url           = var.ecr_urls["${lower(var.project)}-${lower(var.environment)}-${each.key}"]
    var_image_tag                = each.value.image_tag
    var_aws_cloudwatch_log_group = "/ecs/${lower(var.project)}-${lower(var.environment)}-${each.value.name}"
    var_aws_region               = var.region
    var_task_log_stream_prefix   = "ecs"
    environment                  = jsonencode([
      {name = "USE_AWS_SECRETS", value = "true"},
      {name = "AWS_REGION", value = var.region},
      {name = "FLASK_ENV", value = "production"},
      {name = "REDIS_SECRET_NAME", value = var.redis_secret_name},
      {name = "DB_SECRET_NAME", value = var.db_secret_name},
      {name = "FRONTEND_DB_SECRET_NAME", value = var.frontend_db_secret_name}
    ])
    secrets                      = jsonencode([])
  })

  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn
}

resource "aws_iam_role" "task_execution_role" {
  name = "${lower(var.project)}-${lower(var.environment)}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "task_role" {
  name = "${lower(var.project)}-${lower(var.environment)}-ecs-task-role"

  assume_role_policy = file("${path.module}/../../templates/iam/backend-task-role.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "monitoring_task_policy" {
  name        = "${lower(var.project)}-${lower(var.environment)}-monitoring-task-policy"
  description = "Policy for ECS monitoring tasks"
  policy      = file("${path.module}/../../templates/iam/backend-task-policy.json")
}

resource "aws_iam_role_policy_attachment" "monitoring_task_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.monitoring_task_policy.arn
}

resource "aws_service_discovery_private_dns_namespace" "ecs_private_namespace" {
  name        = "${lower(var.project)}-${lower(var.environment)}.local"
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id
}

resource "aws_ecs_service" "ecs_service" {
  for_each = merge([for service in local.services_config:
    service.tasks
  ]...)

  name            = "${lower(var.project)}-${lower(var.environment)}-${each.key}"
  cluster         = aws_ecs_cluster.ecs_cluster[each.key].id
  task_definition = aws_ecs_task_definition.task_definitions[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"
  enable_ecs_managed_tags = true
  propagate_tags  = "SERVICE"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arns[each.key]
    container_name   = "${lower(var.project)}-${lower(var.environment)}-${each.value.name}"
    container_port   = var.container_ports[each.key]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.ecs_service_discovery[each.key].arn
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_service_discovery_service" "ecs_service_discovery" {
  for_each = merge([for service in local.services_config:
    service.tasks
  ]...)

  name = "${lower(var.project)}-${lower(var.environment)}-${each.key}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs_private_namespace.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_security_group" "ecs_service" {
  name        = "${lower(var.project)}-${lower(var.environment)}-ecs-service-sg"
  description = "Security group for ECS service (independent from ALB)"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.container_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-ecs-service-sg"
  }
}
