resource "outscale_vm" "bastion_vm" {
  image_id     = var.bastion_image_id
  vm_type      = var.bastion_vm_type
  keypair_name = outscale_keypair.bastion_keypair.keypair_name
  subnet_id    = outscale_subnet.subnet_pub.subnet_id
  security_group_ids = [outscale_security_group.bastion_sec_group.id]
  user_data = base64encode(templatefile("${path.module}/cloud-init/bastion.yaml", {
    bastion_ip = outscale_public_ip.bastion_public_ip.public_ip
  }))
  tags {
    key   = "name"
    value = "vm_bastion"
  }
}

resource "outscale_public_ip" "bastion_public_ip" {
  tags {
    key = "name"
    value = "bastion_public_ip"
  }
}

output "bastion_public_ip" {
  value = outscale_public_ip.bastion_public_ip.public_ip
}

resource "outscale_public_ip_link" "ip_link_to_bastion" {
  vm_id     = outscale_vm.bastion_vm.vm_id
  public_ip = outscale_public_ip.bastion_public_ip.public_ip
}

resource "outscale_security_group" "bastion_sec_group" {
  description         = "Groupe de sécurité pour le bastion"
  security_group_name = "bastion_sec_group"
  net_id              = outscale_net.main_net.net_id
  tag = {
    key = "name"
    value = "bastion_sec_group"
  }
}

resource "outscale_security_group_rule" "allow_ping" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion_sec_group.security_group_id
  from_port_range   = "-1"
  to_port_range     = "-1"
  ip_protocol       = "icmp"
  ip_range          = "0.0.0.0/0"
}

resource "outscale_security_group_rule" "allow_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion_sec_group.security_group_id
  from_port_range   = "22"
  to_port_range     = "22"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}
