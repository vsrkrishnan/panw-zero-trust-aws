
locals {
  /*
  bootstrap_options = {
      #mgmt-interface-swap = "enable"
      #plugin-op-commands  = "aws-gwlb-inspect:enable"
      type                = "dhcp-client"
      tplname             = "VM-tempstack"
      dgname              = "VM-DG"
      panorama-server     = var.panorama_host
      vm-auth-key         = var.vm_auth_key
      authcodes           = var.authcodes 
  }

  student_id = random_id.student.id
  */
}

data "aws_ami" "pa-vm" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = var.fw_product_code
  }

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.fw_version}*"]
  }
}

resource "aws_network_interface" "this" {
  for_each = { for interface in var.fw_interfaces: interface.name => interface }

  subnet_id         = var.subnet_ids["${var.vpc_name}-${each.value.subnet_name}"]
  private_ips       = each.value.private_ips
  security_groups   = var.security_groups
  source_dest_check = each.value.source_dest_check
  tags = merge({ Name = "${var.prefix-name-tag}${each.value.name}" }, var.global_tags)
}

resource "aws_eip" "elasticip" {
  network_interface = aws_network_interface.this["vmseries01-mgmt"].id
}

resource "aws_instance" "vm-series" {
  for_each = { for firewall in var.firewalls: firewall.name => firewall }
  ami           = data.aws_ami.pa-vm.id
  instance_type = each.value.instance_type
  tags          = merge({ Name = "${var.prefix-name-tag}${each.value.name}" }, var.global_tags)

  user_data = base64encode(join(",", compact(concat(
    [for k, v in each.value.bootstrap_options : "${k}=${v}"],
    #[lookup(each.value, "bootstrap_bucket", null) != null ? "vmseries-bootstrap-aws-s3bucket=${var.buckets_map[each.value.bootstrap_bucket].name}" : null],
  ))))

  root_block_device {
    delete_on_termination = true
  }

  key_name   = var.ssh_key_name

  dynamic "network_interface" {
    for_each = each.value.interfaces
    content {
      device_index         = network_interface.value.index
      network_interface_id = aws_network_interface.this[network_interface.value.name].id
    }
  }
}

output "ngfw-data-eni" {
  value = aws_network_interface.this["vmseries01-data"].id
}

output "ngfw-mgmt-eni" {
  value = aws_network_interface.this["vmseries01-mgmt"].id
}

output "VM-Series-Image-ID" {
  value = data.aws_ami.pa-vm
}
