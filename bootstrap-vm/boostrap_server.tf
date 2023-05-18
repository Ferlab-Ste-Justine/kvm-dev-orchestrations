resource "libvirt_volume" "bootstrap_vm" {
  name             = "ferlab-bootstrap-vm"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "bootstrap_server" {
  source = "./terraform-libvirt-automation-bootstrap"
  name = "ferlab-automation-bootstrap"
  vcpus = local.params.bootstrap_vm.vcpus
  memory = local.params.bootstrap_vm.memory
  volume_id = libvirt_volume.bootstrap_vm.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = local.params.bootstrap_vm.address.ip
    mac = local.params.bootstrap_vm.address.mac
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  configurations_auto_updater = {
    etcd = {
      key_prefix = "/bootstrap/configurations/"
      endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
      client = {
        certificate = ""
        key = ""
        username = "boostrap"
        password = random_password.boostrap_etcd.result
      }
    }
  }
  systemd_remote = {
    port = 8080
    address = "127.0.0.10"
    tls = {
      ca_certificate = module.bootstrap_ca.certificate
      server_certificate = tls_locally_signed_cert.bootstrap.cert_pem
      server_key = tls_private_key.bootstrap.private_key_pem
    }
  }
  terraform_backend_etcd = {
    enabled = true
    port = 9090
    address = "127.0.0.10"
    tls = {
      ca_certificate = module.bootstrap_ca.certificate
      server_certificate = tls_locally_signed_cert.bootstrap.cert_pem
      server_key = tls_private_key.bootstrap.private_key_pem
    }
    auth = {
      username = "terraform-backend-etcd"
      password = random_password.terraform_backend_etcd.result
    }
    etcd = {
      endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
      client = {
        certificate = ""
        key = ""
        username = "boostrap"
        password = random_password.boostrap_etcd.result
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
    confs_auto_updater_tag = "bootstrap-server-systemd-units-updater"
    systemd_remote_tag = "bootstrap-server-systemd-remote"
    terraform_backend_etcd_tag = "bootstrap-server-backend-etcd"
    node_exporter_tag = "bootstrap-server-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "bootstrap-server"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
    etcd = {
      enabled = false
      key_prefix = ""
      endpoints = []
      ca_certificate = ""
      client = {
        certificate = ""
        key = ""
        username = ""
        password = ""
      }
    }
  }
}