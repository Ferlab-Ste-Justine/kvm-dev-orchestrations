resource "libvirt_network" "ferlab" {
  name = "ferlab"
  mode = "nat"

  addresses = [local.params.network.addresses]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    local_only = true
  }

  autostart = true
}

resource "local_file" "ferlab_network_id" {
  content         = libvirt_network.ferlab.id
  file_permission = "0600"
  filename        = "${path.module}/../shared/network_id"
}
