data "healthcheck_tcp" "etcd" {
    server_auth = {
        ca_cert = module.etcd_ca.certificate
    }
    endpoints = [
        {
            name = "etcd-1"
            address = local.params.etcd.addresses.0.ip
            port = 2379
        },
        {
            name = "etcd-2"
            address = local.params.etcd.addresses.1.ip
            port = 2379
        },
        {
            name = "etcd-3"
            address = local.params.etcd.addresses.2.ip
            port = 2379
        }
    ]
    /*maintenance = [
        {
            name = "etcd-1"
        }
    ]*/
}

data "healthcheck_filter" "etcd" {
    up = data.healthcheck_tcp.etcd.up
    down = data.healthcheck_tcp.etcd.down
}

resource "local_file" "etcd_status" {
  content         = templatefile(
    "${path.module}/templates/etcd_status.md.tpl",
    {
      effective = data.healthcheck_filter.etcd.endpoints
      up = data.healthcheck_tcp.etcd.up
      down = data.healthcheck_tcp.etcd.down
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd_status.md"
}