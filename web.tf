resource "outscale_vm" "vm-web" {
  count        = var.web_vm_count
  image_id     = var.web_image_id
  vm_type      = var.web_vm_type
  keypair_name = outscale_keypair.bastion_keypair.keypair_name
  security_group_ids = [outscale_security_group.bastion_sec_group.security_group_id]
  subnet_id    = outscale_subnet.subnet_priv.subnet_id
  user_data = base64encode(templatefile("${path.module}/cloud-init/web.yaml", {
    vm_index = count.index,
  })
  )

  tags {
    key   = "name"
    value = "vm-web-${count.index}"
  }
}

output "web_private_ips" {
    value = [for vm in outscale_vm.vm-web : vm.private_ip]
}

