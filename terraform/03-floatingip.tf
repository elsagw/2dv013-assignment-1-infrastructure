resource "openstack_networking_floatingip_v2" "webapp_float_ip" {

  pool = data.openstack_networking_network_v2.public_network.name
}


resource "openstack_networking_floatingip_associate_v2" "webapp_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.webapp_float_ip.address
  port_id     = openstack_networking_port_v2.webapp_port.id
}


resource "openstack_networking_floatingip_v2" "database_float_ip" {

  pool = data.openstack_networking_network_v2.public_network.name
}


resource "openstack_networking_floatingip_associate_v2" "database_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.database_float_ip.address
  port_id     = openstack_networking_port_v2.database_port.id
}
