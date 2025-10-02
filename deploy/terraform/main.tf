# Terraform configuration file for OpenStack
# This configuration creates a network, subnet, router, security group,
# three compute instances (2 webservers + 1 loadbalancer), and associates floating IPs

# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  auth_url = var.auth_url
}

# Create a network
resource "openstack_networking_network_v2" "the_network" {
  name           = var.network_name
  admin_state_up = "true"
}

# Create a subnet
resource "openstack_networking_subnet_v2" "the_subnet" {
  network_id = openstack_networking_network_v2.the_network.id
  cidr       = var.subnet_cidr
}

# Create a router
resource "openstack_networking_router_v2" "the_router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = var.external_network_id
}

# Attach the subnet to the router
resource "openstack_networking_router_interface_v2" "the_router_interface" {
  router_id = openstack_networking_router_v2.the_router.id
  subnet_id = openstack_networking_subnet_v2.the_subnet.id
}

# Create a security group
resource "openstack_networking_secgroup_v2" "the_secgroup" {
  name        = var.security_group_name
  description = "Security group for assignment 1"
}

# Security group rules
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.the_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.the_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_loadbalancer" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8082
  port_range_max    = 8082
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.the_secgroup.id
}

# Create webservers
resource "openstack_compute_instance_v2" "webservers" {
  count           = 2
  name            = "webserver${count.index + 1}"
  image_name      = var.image_name
  flavor_id       = var.flavor_id
  key_pair        = var.key_name
  security_groups = [openstack_networking_secgroup_v2.the_secgroup.name]

  network {
    name = openstack_networking_network_v2.the_network.name
    port = openstack_networking_port_v2.webserver_ports[count.index].id
  }

  depends_on = [openstack_networking_port_v2.webserver_ports]
}

# Create load balancer
resource "openstack_compute_instance_v2" "loadbalancer" {
  name            = "loadbalancer"
  image_name      = var.image_name
  flavor_id       = var.flavor_id
  key_pair        = var.key_name
  security_groups = [openstack_networking_secgroup_v2.the_secgroup.name]

  network {
    name = openstack_networking_network_v2.the_network.name
    port = openstack_networking_port_v2.loadbalancer_port.id
  }

  depends_on = [openstack_networking_port_v2.loadbalancer_port]
}

# Create ports for webservers
resource "openstack_networking_port_v2" "webserver_ports" {
  count              = 2
  name               = "port_webserver${count.index + 1}"
  network_id         = openstack_networking_network_v2.the_network.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.the_secgroup.id]
  depends_on         = [openstack_networking_subnet_v2.the_subnet]
}

# Create port for load balancer
resource "openstack_networking_port_v2" "loadbalancer_port" {
  name               = "port_loadbalancer"
  network_id         = openstack_networking_network_v2.the_network.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.the_secgroup.id]
  depends_on         = [openstack_networking_subnet_v2.the_subnet]
}

# Create floating IP for load balancer (only this one needs external access)
resource "openstack_networking_floatingip_v2" "loadbalancer_floatip" {
  pool = var.floating_ip_pool
}

# Associate floating IP to load balancer
resource "openstack_networking_floatingip_associate_v2" "loadbalancer_floatip" {
  floating_ip = openstack_networking_floatingip_v2.loadbalancer_floatip.address
  port_id     = openstack_networking_port_v2.loadbalancer_port.id
}