terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    netaddr = {
      source = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.5.1"
    }
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = "= 0.11.0"
    }
    healthcheck = {
      source = "Ferlab-Ste-Justine/healthcheck"
      version = "= 0.3.0"
    }
  }
  required_version = ">= 1.0.0"
}
