data "healthcheck_tcp" "postgres_lb" {
    server_auth = {
        ca_cert = module.postgres_ca.certificate
        override_server_name = "postgres.ferlab.lan"
    }
    endpoints = [
        {
            name = "postgres-lb-1"
            address = netaddr_address_ipv4.postgres_lb.0.address
            port = 4443
        }
    ]
    maintenance = []
}

data "healthcheck_filter" "postgres_lb" {
    up = data.healthcheck_tcp.postgres_lb.up
    down = data.healthcheck_tcp.postgres_lb.down
}

resource "local_file" "postgres_lb_status" {
  content         = templatefile(
    "${path.module}/templates/postgres_lb_status.md.tpl",
    {
      effective = data.healthcheck_filter.postgres_lb.endpoints
      up = data.healthcheck_tcp.postgres_lb.up
      down = data.healthcheck_tcp.postgres_lb.down
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_lb_status.md"
}