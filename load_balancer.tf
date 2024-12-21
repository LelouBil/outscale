resource "outscale_load_balancer" "private_load_balancer" {
  load_balancer_name = var.load_balancer_name
  listeners {
    backend_port           = 80
    backend_protocol       = "HTTP"
    load_balancer_protocol = "HTTP"
    load_balancer_port     = 80
  }
  # listeners {
  #   backend_port = 8080
  #   backend_protocol = "HTTP"
  #   load_balancer_protocol = "HTTP"
  #   load_balancer_port = 8080
  # }
  subnets = [outscale_subnet.subnet_priv.subnet_id]
  load_balancer_type = "internet-facing"
  security_groups = [outscale_security_group.web_sec_group.security_group_id]
  tags {
    key   = "name"
    value = "terraform-internet-private-lb"
  }
  public_ip = outscale_public_ip.lb_public_ip.public_ip
}

resource "outscale_security_group" "web_sec_group" {
  net_id      = outscale_net.main_net.net_id
  description = "Security group for web servers"
  tags {
    key   = "name"
    value = "web_sec_group"
  }
}

resource "outscale_security_group_rule" "web_sec_group_rule" {
  security_group_id = outscale_security_group.web_sec_group.security_group_id
  flow = "Inbound"
  ip_protocol = "tcp"
  from_port_range = 80
  to_port_range = 80
  ip_range = "0.0.0.0/0"
}

resource "outscale_public_ip" "lb_public_ip" {
  tags {
    key   = "name"
    value = "terraform-lb-public-ip"
  }
}

output "lb_public_ip" {
  value = outscale_public_ip.lb_public_ip.public_ip
}

# Enregistrement des VMs dans le LB
resource "outscale_load_balancer_vms" "backend_web" {
  count = length(outscale_vm.vm-web)
  load_balancer_name = outscale_load_balancer.private_load_balancer.load_balancer_name
  backend_vm_ids = [outscale_vm.vm-web[count.index].vm_id]
}
# Configuration de la vérification de l'état de santé des VM
resource "outscale_load_balancer_attributes" "health_check_as" {
  load_balancer_name = outscale_load_balancer.private_load_balancer.load_balancer_name
  health_check {
    healthy_threshold = 10
    check_interval    = 30
    path              = "/"
    port              = 80

    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }
}
