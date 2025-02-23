provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "envoy_transport_control_plane" {
  key = "/ferlab/envoy-transport-control-plane/"
}

resource "etcd_role" "envoy_transport_control_plane" {
  name = "envoy-transport-control-plane"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.envoy_transport_control_plane.key
    range_end = data.etcd_prefix_range_end.envoy_transport_control_plane.range_end
  }
}

resource "random_password" "envoy_transport_control_plane" {
  length           = 16
  special          = false
}

resource "etcd_user" "envoy_transport_control_plane" {
  username = "envoy-transport-control-plane"
  password = random_password.envoy_transport_control_plane.result
  roles = [etcd_role.envoy_transport_control_plane.name]
}