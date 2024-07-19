terraform {
  required_providers {
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = "= 0.6.1"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.6.14"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.1"
    }
    netaddr = {
      source  = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.0.5"
    }
  }
  required_version = ">= 1.0.0"
}
