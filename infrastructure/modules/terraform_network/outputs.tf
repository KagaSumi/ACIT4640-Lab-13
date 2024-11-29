output "vpc_id" {
    value = aws_vpc.main.id
}

output "subnet" {
    value = aws_subnet.subnets
}

output "public_sg" {
    value = aws_security_group.public.id

}
output "private_sg" {
    value = aws_security_group.private.id
}
