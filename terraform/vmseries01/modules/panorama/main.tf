

data "aws_ami" "panorama" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = var.panorama_product_code
  }

  filter {
    name   = "name"
    values = ["Panorama-AWS-${var.panorama_version}*"]
  }
}

resource "aws_network_interface" "private" {
  subnet_id       = var.subnet_ids["${var.vpc_name}-${var.panorama.subnet_name}"]
  private_ips     = var.panorama.private_ips
  security_groups = var.security_groups
  tags = merge({ Name = "${var.prefix-name-tag}${var.panorama.name}-primary-interface" }, var.global_tags)
}

resource "aws_instance" "this" {
  ami                         = "ami-01f123f4cdd250a8b"
  instance_type               = var.panorama.instance_type
  key_name                    = var.ssh_key_name
  network_interface {
    network_interface_id = aws_network_interface.private.id
    device_index = 0
  }

  tags = merge({ Name = "${var.prefix-name-tag}${var.panorama.name}" }, var.global_tags)
}

resource "aws_eip" "elasticip" {
  instance = aws_instance.this.id
}

output "Panorama-Image-ID" {
  value = data.aws_ami.panorama
}
