
resource "local_file" "ansible_inventory"{
  content = templatefile("./templates/inventory.tmpl",
  {
    webapp_ip           = openstack_networking_floatingip_v2.webapp_float_ip.address
    database_ip          = openstack_networking_floatingip_v2.database_float_ip.address
    database_private_ip  = openstack_compute_instance_v2.database.access_ip_v4
  }
  )
  filename = "../ansible/inventory"
}


resource "null_resource" "wait_ssh_webapp" {

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file(var.identity_file)}"
    host     = openstack_networking_floatingip_v2.webapp_float_ip.address
  }
  provisioner "remote-exec" {
    inline = [
      "echo hello from `hostname`"
    ]
  }
    triggers = {
    always_run = "${timestamp()}"
  }
   depends_on = [local_file.ansible_inventory, openstack_compute_instance_v2.webapp, openstack_networking_router_interface_v2.router_interface]
}


resource "null_resource" "wait_ssh_database" {

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file(var.identity_file)}"
    host     = openstack_networking_floatingip_v2.database_float_ip.address
  }
  provisioner "remote-exec" {
    inline = [
      "echo hello from `hostname`"
    ]
  }
    triggers = {
    always_run = "${timestamp()}"
  }
   depends_on = [local_file.ansible_inventory, openstack_compute_instance_v2.database, openstack_networking_router_interface_v2.router_interface]
}


resource "null_resource" "ansible-deploy" {

  depends_on = [
                 openstack_networking_floatingip_associate_v2.webapp_fip_association,
                 openstack_networking_floatingip_associate_v2.database_fip_association,
                 local_file.ansible_inventory,
                 openstack_compute_instance_v2.webapp,
                 openstack_compute_instance_v2.database,
                 null_resource.wait_ssh_webapp,
                 null_resource.wait_ssh_database
                 ]

  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_files_relative_path}/inventory ${var.ansible_files_relative_path}/playbookA1.yml --extra-vars=\"ansible_ssh_private_key_file=${var.identity_file} app_port=${var.app_port}\""

  }
}