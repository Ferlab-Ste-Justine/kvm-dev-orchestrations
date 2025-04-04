data "healthcheck_http" "lb" {
    server_auth = {
        ca_cert = module.k8_certificates.ca_certificate
    }
    path = "/livez"
    status_codes = [200]
    endpoints = [
        {
            name = "lb-1"
            address = netaddr_address_ipv4.k8_lb.0.address
            port = 6443
        }
    ]
    /*maintenance = [
        {
            name = "lb-1"
        }
    ]*/
}

data "healthcheck_filter" "lb" {
    up = data.healthcheck_http.lb.up
    down = data.healthcheck_http.lb.down
}

resource "local_file" "lb_status" {
  content         = templatefile(
    "${path.module}/templates/k8_lb_status.md.tpl",
    {
      effective = data.healthcheck_filter.lb.endpoints
      up = data.healthcheck_http.lb.up
      down = data.healthcheck_http.lb.down
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/k8_lb_status.md"
}