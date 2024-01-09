###################
# Gandi Resources #
###################

resource "gandi_livedns_record" "asciinema_server_dns_record_v4" {
  count = (var.manage_dns_record_using_livedns ? 1 : 0)
  name  = var.asciinema_server_subdomain
  ttl   = 300
  type  = "A"
  values = ["${local.asciinema_server_public_ip}"]
  zone = var.asciinema_server_domain_apex
}
