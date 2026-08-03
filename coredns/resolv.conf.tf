resource "local_file" "nameserver_record" { /* export me : sudo sh -c "cat ../shared/resolv.conf >> /etc/resolv.conf" */
  filename = "../shared/resolv.conf"
  content   = "nameserver ${resource.netaddr_address_ipv4.coredns.address}"
}
