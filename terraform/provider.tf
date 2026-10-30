

# Instructions from: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
# Define the providers --> openstack in our case
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0" #48
    }
  }
}

#user_name, tenant, password, region taken from our environment variable after sourcing our RC file
provider "openstack" {
  auth_url    = "https://cumulus.lnu.se:5000/v3"
}
