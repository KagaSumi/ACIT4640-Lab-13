variable "aws_vpc_id" {
  description = "AWS VPC information"
}

variable "domain_name" {
  description = "DNS domain name"
}

variable "ttl" {
  description = "TTL of DNS records"
  default = "300"
}

variable "instances" {
  description = "Collection of ec2 instances"
}
