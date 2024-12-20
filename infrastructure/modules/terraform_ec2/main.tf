resource "aws_instance" "ec2_instance" {

    for_each = var.instance_configs

    ami = each.value.ami_id
    instance_type = each.value.instance_type
    key_name = each.value.ssh_key_name
    security_groups = [each.value.security_groups]
    subnet_id = each.value.subnet_id
    tags = {
        Name = each.key
        Server_Role = each.value.role
        Project = "lab13"
    }

    user_data = <<-EOF
                #!/bin/bash
                hostnamectl set-hostname ${each.key}
                EOF
}
