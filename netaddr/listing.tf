data "netaddr_address_list_ipv4" "ip" {
  range_id = netaddr_range_ipv4.ip.id
}

resource "local_file" "ips_list" {
  content         = templatefile(
    "${path.module}/templates/ips.md.tpl",
    {
      ferlab = data.netaddr_address_list_ipv4.ip.addresses
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/ips.md"
}