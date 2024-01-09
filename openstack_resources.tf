#######################
# OpenStack Resources #
#######################

locals {
  private_subnet_cidr  = "10.0.1.0/24"
  db_server_private_ip = "10.0.1.101"
  asciinema_server_private_ip = [
    for p in openstack_compute_instance_v2.asciinema_server.network :
    p if p.uuid == openstack_networking_network_v2.asciinema_private_network.id
  ][0].fixed_ip_v4
  asciinema_server_public_ip = [
    for p in openstack_compute_instance_v2.asciinema_server.network :
  p if p.name == "public"][0].fixed_ip_v4
  db_server_public_ip = [
    for p in openstack_compute_instance_v2.db_server.network :
  p if p.name == "public"][0].fixed_ip_v4
}


data "openstack_images_image_ids_v2" "images" {
  name = var.image_name
  sort = "updated_at"
}

resource "openstack_compute_keypair_v2" "admin_keypair" {
  name       = "asciinema_admin_pubkey"
  public_key = var.admin_ssh_pubkey
}

# Private network

resource "openstack_networking_network_v2" "asciinema_private_network" {
  name = "asciinema_private_network"
}

resource "openstack_networking_subnet_v2" "asciinema_private_subnet" {
  name            = "asciinema_private_subnet"
  network_id      = openstack_networking_network_v2.asciinema_private_network.id
  ip_version      = 4
  no_gateway      = true
  dns_nameservers = ["0.0.0.0"]
  cidr            = local.private_subnet_cidr
}

# Database server

resource "openstack_blockstorage_volume_v3" "db_boot" {
  name = "db_boot"
  size = 25
  # Takes the latest uploaded image by name
  image_id = data.openstack_images_image_ids_v2.images.ids[0]
}

resource "openstack_compute_instance_v2" "db_server" {
  name        = "db_server"
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.admin_keypair.name
  user_data = templatefile("./userdata/db.sh.tftpl", {
    db_password = random_password.db_password.result,
    asciinema_server_ip = local.asciinema_server_private_ip,
    my_private_ip = local.db_server_private_ip,
  })

  block_device {
    uuid             = openstack_blockstorage_volume_v3.db_boot.id
    source_type      = "volume"
    boot_index       = 0
    destination_type = "volume"
  }

  network {
    name = "public"
  }

  network {
    uuid        = openstack_networking_network_v2.asciinema_private_network.id
    # Allows to specify a specific IP in the private subnet (can be easier to reference elsewhere):
    fixed_ip_v4 = local.db_server_private_ip
  }
}

# Asciinema server

resource "openstack_networking_port_v2" "asciinema_server_port" {
  network_id = openstack_networking_network_v2.asciinema_private_network.id
}

resource "openstack_blockstorage_volume_v3" "asciinema_server_boot" {
  name = "asciinema_server_boot"
  size = 25
  # Takes the latest uploaded image by name
  image_id = data.openstack_images_image_ids_v2.images.ids[0]
}

resource "openstack_compute_instance_v2" "asciinema_server" {
  name        = "asciinema_server"
  flavor_name = var.flavor
  key_pair    = openstack_compute_keypair_v2.admin_keypair.name
  user_data = templatefile("./userdata/asciinema.sh.tftpl", {
    asciinema_version     = var.asciinema_version,
    server_host           = "${var.asciinema_server_subdomain}.${var.asciinema_server_domain_apex}",
    db_password           = random_password.db_password.result,
    db_server_private_ip  = local.db_server_private_ip,
  })

  block_device {
    uuid             = openstack_blockstorage_volume_v3.asciinema_server_boot.id
    source_type      = "volume"
    boot_index       = 0
    destination_type = "volume"
  }

  network {
    name = "public"
  }

  network {
    # Specifying a network uuid lets OpenStack choose an IP in one of its v4 subnet(s)
    uuid = openstack_networking_network_v2.asciinema_private_network.id
  }
}
