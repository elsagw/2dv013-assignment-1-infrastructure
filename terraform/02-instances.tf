


resource "openstack_compute_instance_v2" "webapp" {

  flavor_id         = var.flavor_id
  key_pair          = var.key_name
  name              = "webappA1"
  image_name        = var.server_image_name
  availability_zone = var.availability_zone
  depends_on = [
    openstack_networking_router_interface_v2.router_interface,  openstack_networking_network_v2.network, openstack_networking_secgroup_v2.ssh, openstack_networking_port_v2.webapp_port
  ]
  network {
    port = openstack_networking_port_v2.webapp_port.id
  }
}

resource "openstack_compute_instance_v2" "database" {

  flavor_id         = var.flavor_id
  key_pair          = var.key_name
  name              = "databaseA1"
  image_name        = var.server_image_name
  availability_zone = var.availability_zone
  depends_on = [
    openstack_networking_router_interface_v2.router_interface,  openstack_networking_network_v2.network, openstack_networking_secgroup_v2.ssh, openstack_networking_port_v2.database_port
  ]
  network {
    port = openstack_networking_port_v2.database_port.id
  }
}
