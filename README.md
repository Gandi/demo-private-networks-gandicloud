# Asciinema-server-opentofu

Simple terraform resources to deploy an asciinema-server on GandiCloud VPS, using either [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/) and a GandiCloud VPS private network.

This repository is published as a resource to go along [this Gandi news article](https://news.gandi.net/fr/2024/01/applications-multi-serveurs-avec-reseaux-prives-gandicloud-vps/)

## Disclaimer

Please read [the comments section](#comments) before deploying this, as this repository was made as a demo for the GandiCloud private network feature and not intended for production.

## How to

### Copy terraform vars template

```
cp terraform.tfvars.example terraform.tfvars
```

### Edit the file with your own values

| Key                              | Example Value                 | Description                                                                                                                                       |
|----------------------------------|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| asciinema_server_domain_apex     | "example.local"               | Bare domain name (without subdomain part) to deploy the asciinema server on                                                                       |
| asciinema_server_subdomain       | "asciinema"                   | Subdomain of the domain to deploy on                                                                                                              |
| manage_dns_record_using_livedns  | true                          | Wether to modify the DNS zone of the above domain using the [go-gandi terraform provider](https://registry.terraform.io/providers/go-gandi/gandi) |
| admin_ssh_pubkey                 | "change-to-your-ssh-pubkey"   | SSH public key to authorize on the servers deployed                                                                                               |

You can check the other available variables that can be set in [variables.tf](./variables.tf).

### Init & run using tofu

For the nix users, a [`flake.nix`](./flake.nix) provides a shell with opentofu and the asciinema client; run `nix develop`.

Otherwise, you need to install either [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/) (tested with `opentofu v1.6.0-dev`).

You also need to source your OpenStack credentials, which can be done [following this documentation](https://docs.gandi.net/en/cloud/vps/api/index.html#prepare-your-environment-to-use-the-openstack-cli)

Finally, you need to provide a Gandi Personal Access Token through the variable `gandi_personal_access_token` if `manage_dns_record_using_livedns` is true. It can be sourced using:

```
source ./personal_access_token.sh
```

Once you have your client ready, run:

```
tofu init
tofu apply
```

Then, watch your deployment happen! Once done, note that cloud-init will still take a few seconds to run in your servers, to install and start the required services.

You can ssh into your server and check `/var/log/cloud-init-output.log` to check if everything went well.

Finally, you can visit your asciinema server using your favorite web browser.

### Record using your asciinema server instance

You can check instructions on the [asciinema-server official repository](https://github.com/asciinema/asciinema-server#setting-up-your-own-asciinema-web-app-instance) to know how to configure your client to use your new server.

Basically:
```
ASCIINEMA_API_URL=https://your.asciinema.host asciinema rec
```

## Comments

The goal of this repository is to demonstrate a use case of the GandiCloud VPS private networks. As such, it was not made for production as it is missing a bunch of important things, such as:

- HTTPS
- backups
- registrations are open by default (see the `SIGN_UP_DISABLED` variable in `.env.demo`)
- included SMTP server is not correctly authenticated (SPF, DKIM... The emails might go into your spam folder)

The asciinema server is deployed as described in the [asciinema installation guide](https://github.com/asciinema/asciinema-server/wiki/Installation-guide), relying on podman and podman-compose to run the provided containers.

Some other GandiCloud VPS features that you might be interested in:

- [Security groups](https://docs.openstack.org/nova/victoria/admin/security-groups.html) can be used to add firewalling to your servers, declared [in your terraform configuration](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2)
- Attach an additional volume to your server to store its data (asciinema recordings for example in this deployment); this can help you separate this data from your system and manage it independently (detach it from your server and attach it to another, configure auto-snapshots, etc),
- [Snapshots](https://docs.gandi.net/en/cloud/vps/resource_management/snapshots.html) can help you rollback to a previous configuration of your servers or restore your data in case you accidentally delete the content. You can request manual snapshot through the OpenStack API (e.g. CLI), or configure auto-snapshots in your Gandi web admin interface.

## About private networks in GandiCloud VPS

To get more information on the private network feature on GandiCloud VPS, you can check:

- the [Gandi documentation](https://docs.gandi.net/en/cloud/vps/resource_management/private_networks.html)
- the terraform resources definition in [main.tf](./main.tf).

In this deployment, one private IP is declared explicitely (for the database server, see `local.db_server_private_ip`) and one is chosen dynamically by OpenStack (which powers the GandiCloud VPS platform), for the asciinema server. In both cases, the server can get its IPs using DHCP as this service is provided by OpenStack.
