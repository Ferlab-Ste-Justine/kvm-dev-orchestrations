/*module "postgres_1" {
  count = local.cluster_state.cluster.0.up ? 1 : 0
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-libvirt-postgres-server.git?ref=hotfix/v3"
  name = "ferlab-postgres-1"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_1.0.id
  libvirt_network = {
    network_id = "b5433123-e621-4662-a8af-4a0ab0af563a"
    ip = netaddr_address_ipv4.postgres.0.address
    mac = netaddr_address_mac.postgres.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca = module.postgres_ca
    certificate = {
      domains              = ["postgres.ferlab.lan", "load-balancer.postgres.ferlab.lan", "server.postgres.ferlab.lan", netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips            = [netaddr_address_ipv4.postgres_lb.0.address]
      organization         = "Ferlab"
      validity_period      = 100 * 365 * 24
      early_renewal_period = 365 * 24
    }
  }
  etcd = {
    hosts = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-1"
    ttl                    = 60
    loop_wait              = 5
    retry_timeout          = 10
    master_start_timeout   = 600
    master_stop_timeout    = 600
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

module "postgres_2" {
  count = local.cluster_state.cluster.1.up ? 1 : 0
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-libvirt-postgres-server.git?ref=hotfix/v3"
  name = "ferlab-postgres-2"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_2.0.id
  libvirt_network = {
    network_id = "b5433123-e621-4662-a8af-4a0ab0af563a"
    ip = netaddr_address_ipv4.postgres.1.address
    mac = netaddr_address_mac.postgres.1.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca = module.postgres_ca
    certificate = {
      domains              = ["postgres.ferlab.lan", "load-balancer.postgres.ferlab.lan", "server.postgres.ferlab.lan", netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips            = [netaddr_address_ipv4.postgres_lb.0.address]
      organization         = "Ferlab"
      validity_period      = 100 * 365 * 24
      early_renewal_period = 365 * 24
    }
  }
  etcd = {
    hosts = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-2"
    ttl                    = 60
    loop_wait              = 5
    retry_timeout          = 10
    master_start_timeout   = 600
    master_stop_timeout    = 600
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

module "postgres_3" {
  count = local.cluster_state.cluster.2.up ? 1 : 0
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-libvirt-postgres-server.git?ref=hotfix/v3"
  name = "ferlab-postgres-3"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_3.0.id
  libvirt_network = {
    network_id = "b5433123-e621-4662-a8af-4a0ab0af563a"
    ip = netaddr_address_ipv4.postgres.2.address
    mac = netaddr_address_mac.postgres.2.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca = module.postgres_ca
    certificate = {
      domains              = ["postgres.ferlab.lan", "load-balancer.postgres.ferlab.lan", "server.postgres.ferlab.lan", netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips            = [netaddr_address_ipv4.postgres_lb.0.address]
      organization         = "Ferlab"
      validity_period      = 100 * 365 * 24
      early_renewal_period = 365 * 24
    }
  }
  etcd = {
    hosts = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-3"
    ttl                    = 60
    loop_wait              = 5
    retry_timeout          = 10
    master_start_timeout   = 600
    master_stop_timeout    = 600
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}*/