terraform {
  required_providers {
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = "= 0.9.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.2"
    }
    netaddr = {
      source  = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.0.6"
    }
  }
  required_version = ">= 1.3.0"
}
