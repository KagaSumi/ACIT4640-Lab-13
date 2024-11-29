provider "aws" {
  region = "us-west-2"
}


module "network" {
    source = "./modules/terraform_network/"
    vpc_cidr = "10.0.0.0/16"
    subnets = [
        {
            name = "public"
            cidr_block = "10.0.1.0/16"
            availability_zone = "us-west-2a"
        },
        {
            name = "private"
            cidr_block = "10.0.2.0/16"
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

resource "aws_instance" "instance1" {
  ami             = "ami-03839f1dba75bb628"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet1.id
  key_name        = module.ssh_key.ssh_key_name
  security_groups = [aws_security_group.main.id]
  tags = {
    Name = "i1"
  }
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname i1
              EOF
}

resource "aws_instance" "instance2" {
  ami             = "ami-03839f1dba75bb628"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet2.id
  security_groups = [aws_security_group.main.id]
  key_name        = module.ssh_key.ssh_key_name
  tags = {
    Name = "i2"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname i2
              EOF

}

module "ec2" {
  source = "./modules/terraform_ec2_multiple"
  
  instance_configs = {
    w01 = {
      ami         = "ami-03839f1dba75bb628"
      instance_type  = "t2.micro"
      subnet_id      = aws_subnet.subnet1.id
      security_groups = module.network.public_sg.id
      ssh_key_name   = module.ssh_key.ssh_key_name
    }
    b01 = {
      ami         = "ami-03839f1dba75bb628"
      instance_type           = "t2.micro"
      subnet_id         = aws_subnet.subnet2.id
      security_groups = module.network.private_sg.id
      ssh_key_name   = module.ssh_key.ssh_key_name
    }
  }
}


resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "lab13.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_route53_zone" "main" {
  name = "lab13.internal"
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "instance1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.instance1.tags.Name}.lab13.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.instance1.private_ip]
}

resource "aws_route53_record" "instance2" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.instance2.tags.Name}.lab13.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.instance2.private_ip]

}

module "ssh_key" {
  source       = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ssh_key_pair.git"
  ssh_key_name = "acit_4640_lab_13"
  output_dir   = path.root
}

module "connect_script" {
  source           = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ec2_connection_script.git"
  ec2_instances    = { "i1" = aws_instance.instance1, "i2" = aws_instance.instance2 }
  output_file_path = "${path.root}/connect_vars.sh"
  ssh_key_file     = module.ssh_key.priv_key_file
  ssh_user_name    = "ubuntu"
}
