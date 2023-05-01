data "netaddr_address_list_ipv4" "ip" {
  range_id = netaddr_range_ipv4.ip.id
  depends_on = [
    netaddr_address_ipv4.coredns,
    netaddr_address_ipv4.k8_masters,
    netaddr_address_ipv4.k8_workers,
    netaddr_address_ipv4.k8_lb,
    netaddr_address_ipv4.k8_bastion,
    netaddr_address_ipv4.postgres,
    netaddr_address_ipv4.postgres_lb,
    netaddr_address_ipv4.nfs,
    netaddr_address_ipv4.vault_servers,
    netaddr_address_ipv4.vault_lb,
  ]
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