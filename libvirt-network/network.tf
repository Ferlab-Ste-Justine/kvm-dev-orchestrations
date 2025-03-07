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
