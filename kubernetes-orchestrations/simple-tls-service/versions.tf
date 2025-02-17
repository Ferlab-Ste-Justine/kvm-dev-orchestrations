terraform {
  required_version = ">= 1.0.0"

  required_providers {
    netaddr = {
      source = "Ferlab-Ste-Justine/netaddr"
      version = "= 0.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}