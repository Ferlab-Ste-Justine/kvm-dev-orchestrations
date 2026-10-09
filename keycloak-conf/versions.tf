terraform {
  required_version = ">= 1.5"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = ">=0.11.0"
    }
  }
}