terraform {
  required_version = ">= 1.5.7"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.22.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    # flux = {
    #   source  = "fluxcd/flux"
    #   version = "= 1.0.1"
    # }
  }
}
