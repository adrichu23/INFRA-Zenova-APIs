resource "aws_lb" "main" {
  for_each           = var.alb_configurations
  name               = "${lower(var.project)}-${lower(var.environment)}-${each.key}-alb"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[each.key].id]
  subnets            = var.public_subnet_ids

  idle_timeout               = 120
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Project     = var.project
    Service     = each.key
  }
}

resource "aws_lb_target_group" "main" {
  for_each    = var.alb_configurations
  name        = "${lower(var.project)}-${lower(var.environment)}-${each.key}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = each.value.health_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "https" {
  for_each = {
    for k, v in var.alb_configurations : k => v if v.port == 443
  }

  load_balancer_arn = aws_lb.main[each.key].arn
  port              = each.value.port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
}

resource "aws_lb_listener" "http" {
  for_each = {
    for k, v in var.alb_configurations : k => v if v.port == 80
  }

  load_balancer_arn = aws_lb.main[each.key].arn
  port              = each.value.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
}

resource "aws_security_group" "alb" {
  for_each = var.alb_configurations

  name        = "${lower(var.project)}-${lower(var.environment)}-${each.key}-sg"
  description = "Security group for ${each.key} ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = each.value.port
    to_port     = each.value.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}