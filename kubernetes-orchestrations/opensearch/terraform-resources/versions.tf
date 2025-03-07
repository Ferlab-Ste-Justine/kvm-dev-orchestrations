terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "= 2.3.1"
    }
    opensearch-ferlab = {
      source  = "Ferlab-Ste-Justine/opensearch"
      version = "= 0.1.0"
    }
  }
  required_version = ">= 1.0.0"
}
