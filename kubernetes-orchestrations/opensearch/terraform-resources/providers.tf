provider "opensearch" {
  url              = local.opensearch_url
  cacert_file      = local.opensearch_cacert_file
  client_cert_path = local.opensearch_client_cert_path
  client_key_path  = local.opensearch_client_key_path
}

provider "opensearch-ferlab" {
  endpoints   = local.opensearch_url
  ca_cert     = local.opensearch_cacert_file
  client_cert = local.opensearch_client_cert_path
  client_key  = local.opensearch_client_key_path
}
