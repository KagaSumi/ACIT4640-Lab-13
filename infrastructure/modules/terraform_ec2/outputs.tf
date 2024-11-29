output "instances" {
    value = {for instance in aws_instance.ec2_instance: instance.tags.Name => instance}
}