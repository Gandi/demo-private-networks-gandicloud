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

provider "gandi" {
  personal_access_token = var.gandi_personal_access_token
}

###########################
# Gandi related variables #
###########################

variable "manage_dns_record_using_livedns" {
  type        = bool
  description = "Wether to insert/delete the value of `asciinema_server_fqdn` as a DNS record in your Gandi LiveDNS zone"
  default     = false
}

variable "gandi_personal_access_token" {
  type        = string
  description = "Your Personal Access Token (Only if manage_dns_record_using_livedns is true)"
  default     = null
  sensitive   = true
}

################################
# GandiCloud related variables #
################################

variable "flavor" {
  type        = string
  default     = "V-R2"
  description = "Server flavor"
}

variable "image_name" {
  type        = string
  default     = "Debian 12 Bookworm"
  description = "OS image to use"
}

variable "username" {
  type        = string
  default     = "debian"
  description = "Username to use to login"
}

variable "admin_ssh_pubkey" {
  type        = string
  description = "SSH key to authorize"
}

######################################
# asciinema server related variables #
######################################

variable "asciinema_version" {
  type        = string
  default     = "20230826"
  description = "asciinema release name"
}

variable "asciinema_server_domain_apex" {
  type        = string
  description = "Apex domain on which the asciinema server will be publicly exposed"
}

variable "asciinema_server_subdomain" {
  type        = string
  description = "Subdomain on which the asciinema server will be publicly exposed"
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "*-_=+<>"
}

###########
# Outputs #
###########

output "output_message" {
  value = <<EOT
Congrats!

To connect to the DB server: ssh ${var.username}@${local.db_server_public_ip}

To connect to the asciinema server: ssh ${var.username}@${local.asciinema_server_public_ip}

Your private network ${openstack_networking_network_v2.asciinema_private_network.name} has 1 subnet: ${local.private_subnet_cidr}.
  - asciinema server has private IP ${local.asciinema_server_private_ip}
  - DB server has private IP ${local.db_server_private_ip}

To register, you can visit http://${var.asciinema_server_subdomain}.${var.asciinema_server_domain_apex}

To upload your record to your server using the asciinema client:

  ASCIINEMA_API_URL=http://${var.asciinema_server_subdomain}.${var.asciinema_server_domain_apex} asciinema rec

EOT
}
