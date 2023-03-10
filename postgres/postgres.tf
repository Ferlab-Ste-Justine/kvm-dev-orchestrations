resource "libvirt_volume" "postgres_1" {
  name             = "ferlab-postgres-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format           = "qcow2"
}

module "postgres_1" {
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-1"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.postgres.0.address
    mac = data.netaddr_address_mac.postgres.0.address
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
      domains = ["postgres.ferlab.local", "load-balancer.postgres.ferlab.local", "server.postgres.ferlab.local", data.netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips = [data.netaddr_address_ipv4.postgres_lb.0.address]
      organization = "Ferlab"
      validity_period = 100*365*24
      early_renewal_period = 365*24
      key_length = 4096
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
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

resource "libvirt_volume" "postgres_2" {
  name             = "ferlab-postgres-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format           = "qcow2"
}

module "postgres_2" {
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-2"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_2.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.postgres.1.address
    mac = data.netaddr_address_mac.postgres.1.address
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
      domains = ["postgres.ferlab.local", "load-balancer.postgres.ferlab.local", "server.postgres.ferlab.local", data.netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips = [data.netaddr_address_ipv4.postgres_lb.0.address]
      organization = "Ferlab"
      validity_period = 100*365*24
      early_renewal_period = 365*24
      key_length = 4096
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
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}

resource "libvirt_volume" "postgres_3" {
  name             = "ferlab-postgres-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format           = "qcow2"
}

module "postgres_3" {
  source = "./kvm-postgres-server"
  name = "ferlab-postgres-3"
  vcpus = local.params.postgres.servers.vcpus
  memory = local.params.postgres.servers.memory
  volume_id = libvirt_volume.postgres_3.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.postgres.2.address
    mac = data.netaddr_address_mac.postgres.2.address
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
      domains = ["postgres.ferlab.local", "load-balancer.postgres.ferlab.local", "server.postgres.ferlab.local", data.netaddr_address_ipv4.postgres_lb.0.address]
      extra_ips = [data.netaddr_address_ipv4.postgres_lb.0.address]
      organization = "Ferlab"
      validity_period = 100*365*24
      early_renewal_period = 365*24
      key_length = 4096
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
    ttl = 60
    loop_wait = 5
    retry_timeout = 10
    master_start_timeout = 300
    master_stop_timeout = 300
    watchdog_safety_margin = -1
    synchronous_node_count = 1
  }
  depends_on = [
    etcd_range_scoped_state.patroni
  ]
}