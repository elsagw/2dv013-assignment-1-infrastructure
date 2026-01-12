variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "192.168.4.0/24"
}

variable "key_name" {
  type    = string
  default = "Please export an environment variable called TF_VAR_key_name with the name of the key that Terraform should use to build the server among the keys you have in cscloud."
}

variable "identity_file" {
  type    = string
  default = "Please export an environment variable TF_VAR_identity_file with the path to your key for ansible machine. This enables the ansible part to work."
}  

variable "flavor_id" {
  type    = string
  default = "c1-r1-d10"
}

variable "auth_url" {
  description = "OpenStack authentication URL"
  type        = string
  default     = "https://cumulus.lnu.se:5000/v3"
}

variable "network_name" {
  description = "Name of the network to create"
  type        = string
  default     = "assignment1-network"
}

variable "router_name" {
  description = "Name of the router to create"
  type        = string
  default     = "assignment1-router"
}

variable "external_network_id" {
  description = "ID of the external network for floating IPs"
  type        = string
  default     = "31594641-fec9-4b8c-bb86-32553208d1f3"
}

variable "webserver_secgroup_name" {
  description = "Name of the webserver security group"
  type        = string
  default     = "assignment1-webserver-secgroup"
}

variable "loadbalancer_secgroup_name" {
  description = "Name of the load balancer security group"
  type        = string
  default     = "assignment1-loadbalancer-secgroup"
}

variable "image_name" {
  description = "Name of the OS image to use for instances"
  type        = string
  default     = "Ubuntu server 24.04.3 autoupgrade"
}

variable "floating_ip_pool" {
  description = "Pool name for floating IP allocation"
  type        = string
  default     = "campus"
}

variable "webserver_port" {
  type    = string
  default = "80"
}

variable "loadbalancer_port" {
  type    = string
  default = "8082"
}