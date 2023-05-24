resource "libvirt_volume" "postgres_lb_1" {
  name             = "ferlab-postgres-lb-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "postgres_lb_1" {
  source = "./kvm-postgres-load-balancer"
  name = "ferlab-postgres-lb-1"
  vcpus = local.params.postgres.load_balancer.vcpus
  memory = local.params.postgres.load_balancer.memory
  volume_id = libvirt_volume.postgres_lb_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.postgres_lb.0.address
    mac = data.netaddr_address_mac.postgres_lb.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  haproxy = {
    postgres_nodes_max_count   = 3
    postgres_nameserver_ips    = [data.netaddr_address_ipv4.coredns.0.address]
    postgres_domain            = "server.postgres.ferlab.lan"
    patroni_client             = {
      ca_key                           = module.postgres_ca.key
      ca_certificate                   = module.postgres_ca.certificate
      certificate_validity_period      = 100*365*24
      certificate_early_renewal_period = 365*24
    }
    timeouts                   = {
      connect = "15s"
      check   = "15s"
      idle    = "60s"
    }
  }
}