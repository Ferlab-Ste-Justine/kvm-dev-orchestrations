resource "libvirt_volume" "automation_server" {
  name             = "ferlab-automation-server"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "automation_server" {
  source = "./terraform-libvirt-automation-server"
  name = "ferlab-automation-server"
  vcpus = local.params.automation_server.vcpus
  memory = local.params.automation_server.memory
  volume_id = libvirt_volume.automation_server.id
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = local.params.automation_server.address.ip
    mac = local.params.automation_server.address.mac
    gateway = local.params.network.gateway
    dns_servers = [local.params.network.static_range.start]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  systemd_remote = {
    server = {
      port = 8080
      address = "127.0.0.10"
      tls = {
        ca_certificate = module.automation_server_ca.certificate
        server_certificate = tls_locally_signed_cert.automation_server.cert_pem
        server_key = tls_private_key.automation_server.private_key_pem
      }
    }
    client = {
      tls = {
        ca_certificate = module.automation_server_ca.certificate
        client_certificate = tls_locally_signed_cert.automation_server.cert_pem
        client_key = tls_private_key.automation_server.private_key_pem
      }
    }
    sync_directory = "/opt/dynamic-configurations"
  }
  systemd_remote_source = {
    source = local.params.automation_server.dynamic_config.source
    etcd = {
      key_prefix = "/automation-server/configurations/"
      endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
      client = {
        certificate = ""
        key = ""
        username = "automation-server"
        password = random_password.automation_server_etcd.result
      }
    }
    git = {
      repo = local.params.automation_server.dynamic_config.git.systemd.repo
      ref = local.params.automation_server.dynamic_config.git.systemd.ref
      path = local.params.automation_server.dynamic_config.git.systemd.path
      trusted_gpg_keys = local.host_params.accepted_signature != "" ? [file(pathexpand(local.host_params.accepted_signature))] : []
      auth = {
        client_ssh_key         = local.host_params.ssh_key != "" ? file(pathexpand(local.host_params.ssh_key)) : ""
        server_ssh_fingerprint = file("${path.module}/git/known_host")
      }
    }
  }
  terraform_backend_etcd = {
    enabled = true
    server = {
      port = 9090
      address = "127.0.0.10"
      tls = {
        ca_certificate = module.automation_server_ca.certificate
        server_certificate = tls_locally_signed_cert.automation_server.cert_pem
        server_key = tls_private_key.automation_server.private_key_pem
      }
      auth = {
        username = "terraform-backend-etcd"
        password = random_password.terraform_backend_etcd.result
      }
    }
    etcd = {
      endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
      client = {
        certificate = ""
        key = ""
        username = "automation-server"
        password = random_password.automation_server_etcd.result
      }
    }
  }
  bootstrap_configs = concat(
    [
      {
        path = "/opt/i-am-running/i-am-running.sh"
        content = file("${path.module}/startup-logic/simple-service/i-am-running.sh")
      },
      {
        path = "/etc/systemd/system/i-am-running.service"
        content = file("${path.module}/startup-logic/simple-service/i-am-running.service")
      }
    ],
    [
      {
        path = "/opt/timer-in-files/terracd-conf.yml"
        content = file("${path.module}/startup-logic/simple-job/systemd/terracd-conf.yml")
      },
      {
        path = "/etc/systemd/system/time-in-files.service"
        content = file("${path.module}/startup-logic/simple-job/systemd/time-in-files.service")
      },
      {
        path = "/etc/systemd/system/time-in-files.timer"
        content = file("${path.module}/startup-logic/simple-job/systemd/time-in-files.timer")
      }
    ],
    [for filename in fileset("${path.module}/startup-logic/simple-job/terraform", "*"): {
      path = "/opt/terraform/timer-in-files-cloud-init/${filename}"
      content = file("${path.module}/startup-logic/simple-job/terraform/${filename}")
    }]
  )
  bootstrap_services = ["i-am-running.service", "time-in-files.timer"]
  fluentbit = {
    enabled = local.params.logs_forwarding
    systemd_remote_source_tag = "automation-server-systemd-remote-source"
    systemd_remote_tag = "automation-server-systemd-remote"
    terraform_backend_etcd_tag = "automation-server-backend-etcd"
    node_exporter_tag = "automation-server-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "automation-server"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
  }
  fluentbit_dynamic_config = {
    enabled = true
    source = local.params.automation_server.dynamic_config.source
    etcd = {
      key_prefix = "/automation-server/fluent-bit/"
      endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
      client = {
        certificate = ""
        key = ""
        username = "automation-server"
        password = random_password.automation_server_etcd.result
      }
    }
    git = {
      repo = local.params.automation_server.dynamic_config.git.fluentbit.repo
      ref = local.params.automation_server.dynamic_config.git.fluentbit.ref
      path = local.params.automation_server.dynamic_config.git.fluentbit.path
      trusted_gpg_keys = local.host_params.accepted_signature != "" ? [file(pathexpand(local.host_params.accepted_signature))] : []
      auth = {
        client_ssh_key         = local.host_params.ssh_key != "" ? file(pathexpand(local.host_params.ssh_key)) : ""
        server_ssh_fingerprint = file("${path.module}/git/known_host")
      }
    }
  }
}