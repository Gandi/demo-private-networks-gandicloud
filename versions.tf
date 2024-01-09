terraform {
  required_providers {
    openstack = {
      source  = "registry.terraform.io/terraform-provider-openstack/openstack"
      version = ">= 1.28"
    }
    gandi = {
      source  = "registry.terraform.io/go-gandi/gandi"
      version = "1.1.1"
    }
    random = {
      source = "registry.terraform.io/hashicorp/random"
      version = "3.5.1"
    }
  }
}