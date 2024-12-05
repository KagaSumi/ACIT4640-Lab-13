provider "aws" {
    region = var.aws_region
    default_tags {
      tags = {
          Project = var.project_name
      }
    }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].availability_zone 
  map_public_ip_on_launch = true
  tags = {
      Name = var.subnets[count.index].name
  }
}


resource "aws_route_table_association" "subnet_associate" {
  count= length(var.subnets)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "private" {
  name        = "private"
  description = "Allow ssh access"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "public" {
  name        = "public"
  description = "Allow ssh access"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "public_ingress" {
    count = length(var.public_security_group_ingress)
    security_group_id = aws_security_group.public.id
    ip_protocol = var.public_security_group_ingress[count.index].ip_protocol
    from_port = var.public_security_group_ingress[count.index].from_port
    to_port = var.public_security_group_ingress[count.index].to_port
    cidr_ipv4 = var.public_security_group_ingress[count.index].cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "private_ingress" {
    count = length(var.private_security_group_ingress)
    security_group_id = aws_security_group.private.id
    ip_protocol = var.private_security_group_ingress[count.index].ip_protocol
    from_port = var.private_security_group_ingress[count.index].from_port
    to_port = var.private_security_group_ingress[count.index].to_port
    cidr_ipv4 = var.private_security_group_ingress[count.index].cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "public_ingress_vpc" {
    security_group_id = aws_security_group.public.id
    cidr_ipv4 = var.vpc_cidr
    ip_protocol = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "private_ingress_vpc" {
    security_group_id = aws_security_group.private.id
    cidr_ipv4 = var.vpc_cidr
    ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "public_egress" {
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    security_group_id = aws_security_group.public.id
}

resource "aws_vpc_security_group_egress_rule" "private_egress" {
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    security_group_id = aws_security_group.private.id
}
