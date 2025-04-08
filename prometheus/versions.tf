terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    netaddr = {
      source = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.4.0"
    }
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = "= 0.10.0"
    }
  }
  required_version = ">= 1.0.0"
}
