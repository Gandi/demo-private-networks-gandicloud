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
