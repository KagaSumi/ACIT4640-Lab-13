
variable "instance_configs" {
    type = map(object({
        ami_id = string
        instance_type = string
        subnet_id = string
        security_groups = string
        ssh_key_name = string
    }))
    description ="Json-like object of ec2 instances"
}