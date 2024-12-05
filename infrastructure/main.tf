provider "aws" {
  region = "us-west-2"
}

module "network" {
    source = "./modules/terraform_network/"
    vpc_cidr = "10.0.0.0/16"
    subnets = [
        {
            name = "public"
            cidr_block = "10.0.1.0/24"
            availability_zone = "us-west-2a"
        },
        {
            name = "private"
            cidr_block = "10.0.2.0/24"
            availability_zone = "us-west-2b"
        }
    ]
    
    public_security_group_ingress = [
        {
            ip_protocol = "tcp"
            from_port = 22
            to_port = 22
            cidr_ipv4 = "0.0.0.0/24"
        },
        {
            ip_protocol = "tcp"
            from_port = 80
            to_port = 80
            cidr_ipv4 = "0.0.0.0/24"
        }
    ]
    private_security_group_ingress = [
        {
            ip_protocol = "tcp"
            from_port = 22
            to_port = 22
            cidr_ipv4 = "0.0.0.0/24"
        },
    ]
 
    aws_region = "us-west-2"
}

module "ec2" {
  source = "./modules/terraform_ec2"
  
  instance_configs = {
    w01 = {
      ami_id         = "ami-03839f1dba75bb628"
      instance_type  = "t2.micro"
      security_groups = module.network.public_sg_id
      ssh_key_name   = module.ssh_key.ssh_key_name
      subnet_id = module.network.subnets.public.id
      role = "Frontend"
    }
    b01 = {
      ami_id         = "ami-03839f1dba75bb628"
      instance_type           = "t2.micro"
      security_groups = module.network.private_sg_id
      ssh_key_name   = module.ssh_key.ssh_key_name
      subnet_id = module.network.subnets.private.id
      role = "Backend"
    }
  }
}


module "dns" {
    source = "./modules/terraform_dns_dhcp/"
    aws_vpc_id = module.network.vpc_id
    domain_name = "lab13.internal"
    instances = module.ec2.instances
}

module "ssh_key" {
  source       = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ssh_key_pair.git"
  ssh_key_name = "acit_4640_lab_13"
  output_dir   = path.root
}

module "connect_script" {
  source           = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ec2_connection_script.git"
  ec2_instances    = { "w01" = module.ec2.instances.w01, "b01" = module.ec2.instances.b01 }
  output_file_path = "${path.root}/connect_vars.sh"
  ssh_key_file     = module.ssh_key.priv_key_file
  ssh_user_name    = "ubuntu"
}
