data "healthcheck_http" "alertmanager" {
    server_auth = {
        ca_cert = module.alertmanager_ca.certificate
        override_server_name = "alertmanager.ferlab.lan"
    }
    client_auth = {
        cert_auth = {
            cert =  tls_locally_signed_cert.alertmanager.cert_pem
            key = tls_private_key.alertmanager.private_key_pem
        }
    }
    path = "/-/healthy"
    status_codes = [200]
    endpoints = [
        {
            name = "alertmanager-1"
            address = netaddr_address_ipv4.alertmanager.0.address
            port = 9093
        },
        {
            name = "alertmanager-2"
            address = netaddr_address_ipv4.alertmanager.1.address
            port = 9093
        }
    ]
}

data "healthcheck_tcp" "alertmanager" {
    server_auth = {
        ca_cert = module.alertmanager_ca.certificate
        override_server_name = "alertmanager.ferlab.lan"
    }
    client_auth = {
        cert_auth = {
            cert =  tls_locally_signed_cert.alertmanager.cert_pem
            key = tls_private_key.alertmanager.private_key_pem
        }
    }
    endpoints = [
        {
            name = "alertmanager-1"
            address = netaddr_address_ipv4.alertmanager.0.address
            port = 9093
        },
        {
            name = "alertmanager-2"
            address = netaddr_address_ipv4.alertmanager.1.address
            port = 9093
        }
    ]
}

resource "local_file" "alertmanager_status" {
  content         = templatefile(
    "${path.module}/templates/alertmanager_status.md.tpl",
    {
      up = data.healthcheck_http.alertmanager.up
      down = data.healthcheck_http.alertmanager.down
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/alertmanager_status.md"
}