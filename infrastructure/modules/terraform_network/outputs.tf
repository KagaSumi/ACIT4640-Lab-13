output "vpc_id" {
    value = aws_vpc.main.id
}

output "subnets" {
    value = {for subnet in aws_subnet.subnets: subnet.tags.Name => subnet}
}

output "public_sg_id" {
    value = aws_security_group.public.id

}
output "private_sg_id" {
    value = aws_security_group.private.id
}
