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
