
resource "aws_network_interface" "private" {
  subnet_id       = var.subnet_ids["${var.vpc_name}-${var.panorama.subnet_name}"]
  private_ips     = var.panorama.private_ips
  security_groups = [var.security_groups["${var.prefix-name-tag}${var.panorama.security_group}"]]
  tags = merge({ Name = "${var.prefix-name-tag}${var.panorama.name}-primary-interface" }, var.global_tags)
}

resource "aws_instance" "this" {
  ami                         = var.panorama.ami
  instance_type               = var.panorama.instance_type
  key_name                    = var.ssh_key_name
  network_interface {
    network_interface_id = aws_network_interface.private.id
    device_index = 0
  }

  tags = merge({ Name = "${var.prefix-name-tag}${var.panorama.name}" }, var.global_tags)
}

resource "time_sleep" "wait_for_panorama_instance" {
  create_duration = "30s"

  depends_on = [ aws_instance.this ]
}

resource "aws_eip" "elasticip" {
  instance = aws_instance.this.id
}

resource "time_sleep" "wait_for_panorama_ip" {
  create_duration = "30s"

  depends_on = [ aws_eip.elasticip ]
}

output "panorama_ip" {
  value = aws_instance.this.public_ip
}