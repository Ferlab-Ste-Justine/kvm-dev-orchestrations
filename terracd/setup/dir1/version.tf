terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "registry.opentofu.org/hashicorp/local"
      version = "= 2.4.0"
    }
  }
}