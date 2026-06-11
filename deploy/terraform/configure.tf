resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tmpl", {
    WEBSERVER1_IP           = openstack_networking_port_v2.webserver_ports[0].all_fixed_ips[0]
    WEBSERVER2_IP           = openstack_networking_port_v2.webserver_ports[1].all_fixed_ips[0]
    LOADBALANCER_PUBLIC_IP  = openstack_networking_floatingip_v2.loadbalancer_floatip.address
    LOADBALANCER_PRIVATE_IP = openstack_networking_port_v2.loadbalancer_port.all_fixed_ips[0]
    TF_VAR_identity_file    = var.identity_file
    WEBSERVER_PORT          = var.webserver_port
    LOADBALANCER_PORT       = var.loadbalancer_port
  })
  
  filename = "${path.module}/../ansible/inventory-generated"
  
  depends_on = [
    openstack_compute_instance_v2.loadbalancer,
    openstack_compute_instance_v2.webservers,
    openstack_networking_floatingip_associate_v2.loadbalancer_floatip
  ]
}
