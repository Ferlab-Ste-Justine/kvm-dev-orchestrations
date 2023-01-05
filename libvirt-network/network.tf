locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
}

resource "libvirt_network" "ferlab" {
  name = "ferlab"
  mode = "nat"

  addresses = [local.params.addresses]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
  }

  autostart = true
}