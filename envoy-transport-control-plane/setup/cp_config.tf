resource "local_file" "control_plane_config" {
  content         = templatefile(
    "${path.module}/config.yml.tpl",
    {
      etcd_endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../work-env/config.yml"
}

resource "local_file" "control_plane_etcd_auth" {
  content         = "username: \"envoy-transport-control-plane\"\npassword: \"${random_password.envoy_transport_control_plane.result}\""
  file_permission = "0600"
  filename        = "${path.module}/../work-env/etcd_auth.yml"
}