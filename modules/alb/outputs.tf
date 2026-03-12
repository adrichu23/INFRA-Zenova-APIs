output "target_group_arns" {
  value = { for k, v in aws_lb_target_group.main : k => v.arn }
}

output "target_group_arn" {
  value = values(aws_lb_target_group.main)[0].arn
}

output "alb_dns_names" {
  value = { for k, v in aws_lb.main : k => v.dns_name }
}

output "alb_arns" {
  value = { for k, v in aws_lb.main : k => v.arn }
}

output "alb_security_group_ids" {
  value = { for k, v in aws_security_group.alb : k => v.id }
}