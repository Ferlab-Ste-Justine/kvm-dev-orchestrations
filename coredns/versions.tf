terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "= 0.6.14"
    }
    netaddr = {
      source = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.3.0"
    }
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = "= 0.7.0"
    }
  }
  required_version = ">= 1.0.0"
}
