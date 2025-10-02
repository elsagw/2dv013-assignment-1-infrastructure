# Output the load balancer's public IP (this is what users will access)
output "loadbalancer_public_ip" {
  description = "Public IP address of the load balancer - access your website here"
  value       = openstack_networking_floatingip_v2.loadbalancer_floatip.address
}

# Output load balancer's private IP (for Ansible configuration)
output "loadbalancer_private_ip" {
  description = "Private IP address of the load balancer"
  value       = openstack_networking_port_v2.loadbalancer_port.all_fixed_ips[0]
}

# Output webserver private IPs (for Ansible configuration)
output "webserver_private_ips" {
  description = "Private IP addresses of the webservers"
  value       = openstack_networking_port_v2.webserver_ports[*].all_fixed_ips[0]
}

# Output webserver names and IPs together (easy to read)
output "webserver_info" {
  description = "Webserver names and their private IP addresses"
  value = {
    for i in range(2) : 
    "webserver${i + 1}" => openstack_networking_port_v2.webserver_ports[i].all_fixed_ips[0]
  }
}

# Output website URL (convenient for testing)
output "website_url" {
  description = "URL to access your website"
  value       = "http://${openstack_networking_floatingip_v2.loadbalancer_floatip.address}:8082"
}

# Output SSH command for load balancer (convenient for debugging)
output "ssh_loadbalancer" {
  description = "SSH command to connect to load balancer"
  value       = "ssh ubuntu@${openstack_networking_floatingip_v2.loadbalancer_floatip.address}"
}

# Output all server information (useful for Ansible inventory generation)
output "ansible_inventory_info" {
  description = "All server information needed for Ansible inventory"
  value = {
    loadbalancer = {
      public_ip  = openstack_networking_floatingip_v2.loadbalancer_floatip.address
      private_ip = openstack_networking_port_v2.loadbalancer_port.all_fixed_ips[0]
    }
    webservers = {
      for i in range(2) : "webserver${i + 1}" => {
        private_ip = openstack_networking_port_v2.webserver_ports[i].all_fixed_ips[0]
      }
    }
  }
}

// vad man kommer se efter terraform apply
# Outputs:

# ansible_inventory_info = {
#   "loadbalancer" = {
#     "private_ip" = "192.168.1.15"
#     "public_ip" = "130.243.45.67"
#   }
#   "webservers" = {
#     "webserver1" = {
#       "private_ip" = "192.168.1.12"
#     }
#     "webserver2" = {
#       "private_ip" = "192.168.1.13"
#     }
#   }
# }
# loadbalancer_private_ip = "192.168.1.15"
# loadbalancer_public_ip = "130.243.45.67"
# ssh_loadbalancer = "ssh ubuntu@130.243.45.67"
# webserver_info = {
#   "webserver1" = "192.168.1.12"
#   "webserver2" = "192.168.1.13"
# }
# webserver_private_ips = [
#   "192.168.1.12",
#   "192.168.1.13",
# ]
# website_url = "http://130.243.45.67:8082"

# Testa din webbplats: terraform output -raw website_url
# SSH till load balancer: terraform output -raw ssh_loadbalancer
# Få webserver IPs för Ansible: terraform output -json webserver_info