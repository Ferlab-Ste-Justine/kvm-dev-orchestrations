locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
  is_initializing = true
}

resource "libvirt_volume" "etcd_1" {
  name             = "ferlab-etcd-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "etcd_1" {
  source = "./kvm-etcd-server"
  name = "ferlab-etcd-1"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.etcd_1.id
  data_volume_id = local.params.etcd.data_volumes ? libvirt_volume.etcd_1_data.0.id : ""
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = local.params.etcd.addresses.0.ip
    mac = local.params.etcd.addresses.0.mac
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  authentication_bootstrap = {
    bootstrap     = local.is_initializing
    root_password = random_password.etcd_root_password.result
  }
  ca = module.etcd_ca
  cluster = {
    is_initializing = local.is_initializing
    initial_token   = "etcd"
    initial_members = [
      {
        ip = local.params.etcd.addresses.0.ip
        name = "ferlab-etcd-1"
      },
      {
        ip = local.params.etcd.addresses.1.ip
        name = "ferlab-etcd-2"
      },
      {
        ip = local.params.etcd.addresses.2.ip
        name = "ferlab-etcd-3"
      } 
    ]
  }
  etcd = {
    auto_compaction_mode       = "revision"
    auto_compaction_retention  = "1000"
    space_quota                = 8*1024*1024*1024
    grpc_gateway_enabled       = true
    client_cert_auth           = false
  }
}

resource "libvirt_volume" "etcd_2" {
  name             = "ferlab-etcd-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "etcd_2" {
  source = "./kvm-etcd-server"
  name = "ferlab-etcd-2"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.etcd_2.id
  data_volume_id = local.params.etcd.data_volumes ? libvirt_volume.etcd_2_data.0.id : ""
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = local.params.etcd.addresses.1.ip
    mac = local.params.etcd.addresses.1.mac
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  ca = module.etcd_ca
  cluster = {
    is_initializing = true
    initial_token   = "etcd"
    initial_members = [
      {
        ip = local.params.etcd.addresses.0.ip
        name = "ferlab-etcd-1"
      },
      {
        ip = local.params.etcd.addresses.1.ip
        name = "ferlab-etcd-2"
      },
      {
        ip = local.params.etcd.addresses.2.ip
        name = "ferlab-etcd-3"
      }
    ]
  }
  etcd = {
    auto_compaction_mode       = "revision"
    auto_compaction_retention  = "1000"
    space_quota                = 8*1024*1024*1024
    grpc_gateway_enabled       = true
    client_cert_auth           = false
  }
}

resource "libvirt_volume" "etcd_3" {
  name             = "ferlab-etcd-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "etcd_3" {
  source = "./kvm-etcd-server"
  name = "ferlab-etcd-3"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.etcd_3.id
  data_volume_id = local.params.etcd.data_volumes ? libvirt_volume.etcd_3_data.0.id : ""
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = local.params.etcd.addresses.2.ip
    mac = local.params.etcd.addresses.2.mac
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  ca = module.etcd_ca
  cluster = {
    is_initializing = local.is_initializing
    initial_token   = "etcd"
    initial_members = [
      {
        ip = local.params.etcd.addresses.0.ip
        name = "ferlab-etcd-1"
      },
      {
        ip = local.params.etcd.addresses.1.ip
        name = "ferlab-etcd-2"
      },
      {
        ip = local.params.etcd.addresses.2.ip
        name = "ferlab-etcd-3"
      } 
    ]
  }
  etcd = {
    auto_compaction_mode       = "revision"
    auto_compaction_retention  = "1000"
    space_quota                = 8*1024*1024*1024
    grpc_gateway_enabled       = true
    client_cert_auth           = false
  }
}