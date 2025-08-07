resource "local_file" "patroni_conf_provider" {
  content         = templatefile(
    "${path.module}/templates/patroni_conf_provider.tf.tpl",
    {
      servers = [for server in netaddr_address_ipv4.postgres: {
        name = server.name
        ip   = server.address
      }]
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../patroni-conf/provider.tf"
}