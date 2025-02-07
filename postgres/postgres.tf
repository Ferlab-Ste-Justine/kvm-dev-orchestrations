locals {
  is_synchronous = true
  synchronous_settings = {
    strict = true
    synchronous_node_count = 1
  }
}

resource "libvirt_volume" "postgres_1" {
  count = local.cluster_state.cluster.0.up ? 1 : 0
  name             = "ferlab-postgres-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "postgres_1" {
  count = local.cluster_state.cluster.0.up ? 1 : 0
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-1"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_1.0.id
  data_volume_id = local.params.postgres.servers.data_volumes ? libvirt_volume.postgres_1_data.0.id : ""
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.postgres.0.address
    mac = netaddr_address_mac.postgres.0.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca_certificate = module.postgres_ca.certificate
    server_certificate = module.postgres_certificates.server_certificate
    server_key = tls_private_key.postgres_server_key.private_key_pem
  }
  etcd = {
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-1"
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    is_synchronous = local.is_synchronous
    synchronous_settings = local.synchronous_settings
    client_certificate = module.postgres_certificates.client_certificate
    client_key = tls_private_key.patroni_client_key.private_key_pem
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

resource "libvirt_volume" "postgres_2" {
  count = local.cluster_state.cluster.1.up ? 1 : 0
  name             = "ferlab-postgres-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "postgres_2" {
  count = local.cluster_state.cluster.1.up ? 1 : 0
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-2"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_2.0.id
  data_volume_id = local.params.postgres.servers.data_volumes ? libvirt_volume.postgres_2_data.0.id : ""
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.postgres.1.address
    mac = netaddr_address_mac.postgres.1.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca_certificate = module.postgres_ca.certificate
    server_certificate = module.postgres_certificates.server_certificate
    server_key = tls_private_key.postgres_server_key.private_key_pem
  }
  etcd = {
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-2"
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    is_synchronous = local.is_synchronous
    client_certificate = module.postgres_certificates.client_certificate
    client_key = tls_private_key.patroni_client_key.private_key_pem
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

resource "libvirt_volume" "postgres_3" {
  count = local.cluster_state.cluster.2.up ? 1 : 0
  name             = "ferlab-postgres-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "postgres_3" {
  count = local.cluster_state.cluster.2.up ? 1 : 0
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-3"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_3.0.id
  data_volume_id = local.params.postgres.servers.data_volumes ? libvirt_volume.postgres_3_data.0.id : ""
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.postgres.2.address
    mac = netaddr_address_mac.postgres.2.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  postgres = {
    params = local.params.postgres.servers.params
    replicator_password = random_password.postgres_root_password.result
    superuser_password = random_password.postgres_root_password.result
    ca_certificate = module.postgres_ca.certificate
    server_certificate = module.postgres_certificates.server_certificate
    server_key = tls_private_key.postgres_server_key.private_key_pem
  }
  etcd = {
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_cert = file("${path.module}/../shared/etcd-ca.pem")
    username = etcd_user.patroni.username
    password = etcd_user.patroni.password
  }
  patroni = {
    scope = "patroni"
    namespace = "/patroni/"
    name = "postgres-3"
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    is_synchronous = local.is_synchronous
    client_certificate = module.postgres_certificates.client_certificate
    client_key = tls_private_key.patroni_client_key.private_key_pem
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}