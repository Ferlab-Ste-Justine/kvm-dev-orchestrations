resource "libvirt_network" "ferlab" {
  name = "ferlab"
  mode = "nat"

  addresses = [local.params.addresses]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    local_only = true
  }

  autostart = true
}