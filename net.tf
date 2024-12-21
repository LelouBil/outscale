resource "outscale_net" "main_net" {
  ip_range = var.ip_range_net

  tags {
    key = "name"
    value = "main_net"
  }
}

resource "outscale_subnet" "subnet_pub" {
  net_id = outscale_net.main_net.net_id
  ip_range = var.ip_range_sub_pub
  subregion_name = "${var.region}a"
  tags {
    key = "name"
    value = "subnet_pub"
  }
}

resource "outscale_internet_service" "internet_service_pub" {}

resource "outscale_internet_service_link" "net_internet" {
  internet_service_id = outscale_internet_service.internet_service_pub.id
  net_id              = outscale_net.main_net.net_id
}


resource "outscale_route_table" "pub_subnet_routing" {
  net_id = outscale_net.main_net.net_id
  tags {
    key = "name"
    value = "pub_subnet_routing"
  }
}

resource "outscale_route" "pub_subnet_internet_route" {
  destination_ip_range = "0.0.0.0/0"
  route_table_id       = outscale_route_table.pub_subnet_routing.route_table_id
  gateway_id = outscale_internet_service_link.net_internet.id
}


resource "outscale_route_table_link" "pub_subnet_route_table_link" {
  route_table_id = outscale_route_table.pub_subnet_routing.route_table_id
  subnet_id      = outscale_subnet.subnet_pub.subnet_id
}

resource "outscale_subnet" "subnet_priv" {
  net_id = outscale_net.main_net.net_id
  ip_range = var.ip_range_sub_priv
  subregion_name = "${var.region}a"
  tags {
      key = "name"
      value = "subnet_priv"
  }
}


resource "outscale_route" "priv_subnet_nat_route" {
  destination_ip_range = "0.0.0.0/0"
  route_table_id       = outscale_route_table.priv_subnet_routing.route_table_id
  nat_service_id = outscale_nat_service.nat_service.id
}

resource "outscale_route_table" "priv_subnet_routing" {
  net_id = outscale_net.main_net.net_id
  tags {
    key = "name"
    value = "priv_subnet_routing"
  }
}

resource "outscale_route_table_link" "net_route_table_link" {
  route_table_id = outscale_route_table.priv_subnet_routing.route_table_id
  subnet_id      = outscale_subnet.subnet_priv.subnet_id
}


resource "outscale_public_ip" "nat_public_ip" {
  tags {
    key = "name"
    value = "terraform-nat-public-ip"
  }
}

resource "outscale_nat_service" "nat_service" {
  public_ip_id = outscale_public_ip.nat_public_ip.public_ip_id
  subnet_id    = outscale_subnet.subnet_pub.subnet_id
  tags {
    key = "name"
    value = "terraform-nat_service"
  }
}
