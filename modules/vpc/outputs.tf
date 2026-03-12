output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.vpc.id
}

output "public_subnets" {
  description = "IDs of public subnets."
  value       = aws_subnet.subnet_public[*].id
}

output "private_subnets" {
  description = "IDs of private subnets."
  value       = aws_subnet.subnet_private[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.internet_gateway.id
}

output "private_subnets_with_az" {
  description = "Private subnets with their availability zones"
  value = [
    for subnet in aws_subnet.subnet_private : {
      id = subnet.id
      az = subnet.availability_zone
    }
  ]
}
