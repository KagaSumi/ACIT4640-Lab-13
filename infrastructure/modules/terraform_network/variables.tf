variable "vpc_cidr" {
    description = "Cidr block for VPC"
    default = "10.0.0.0/16"
}

variable "subnets" {
    description = "List of Subnets"
}
variable "aws_region" {
    description = "Region"
}
variable "private_security_group_ingress" {
    description = "List of ingress rules for the private sg"
}
variable "public_security_group_ingress" {
    description = "List of ingress rules for the public sg"
}
