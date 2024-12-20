resource "aws_vpc_dhcp_options" "main" {
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = var.aws_vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_route53_zone" "main" {
  name = aws_vpc_dhcp_options.main.domain_name
  vpc {
    vpc_id = var.aws_vpc_id
  }
}

resource "aws_route53_record" "this" {
  for_each = var.instances

  zone_id = aws_route53_zone.main.zone_id
  name    = "${each.value.tags.Name}.${aws_vpc_dhcp_options.main.domain_name}"
  type    = "A"
  ttl     = var.ttl
  records = [each.value.private_ip]
}
