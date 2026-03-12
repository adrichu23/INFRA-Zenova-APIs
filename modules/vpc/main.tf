resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name = "${lower(var.project)}-${lower(var.environment)}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-igw"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-route-public"
  }
}

resource "aws_route_table_association" "association_public" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.route_table_public.id
  depends_on     = [aws_subnet.subnet_public]
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-route-private"
  }
  depends_on = [aws_subnet.subnet_private]
}

resource "aws_route_table_association" "association_private" {
  count          = 3
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_subnet" "subnet_public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]
  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "subnet_private" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-private-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public[0].id


  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  depends_on             = [aws_route_table.route_table_private, aws_nat_gateway.nat_gateway]
}

resource "aws_route" "route_public_igw" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
