# 1. Generate Ansible inventory from template
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

# 2. Wait for SSH on load balancer before running Ansible
resource "null_resource" "wait_ssh_loadbalancer" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.identity_file)
    host        = openstack_networking_floatingip_v2.loadbalancer_floatip.address
    timeout     = "5m"
  }
  
  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection established on load balancer'"
    ]
  }
  
  depends_on = [
    openstack_networking_floatingip_associate_v2.loadbalancer_floatip
  ]
}
