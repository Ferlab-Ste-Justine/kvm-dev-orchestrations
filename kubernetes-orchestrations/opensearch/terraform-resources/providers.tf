provider "opensearch" {
  url              = "https://opensearch.ferlab.lan:9200"
  cacert_file      = "../certificates/opensearch-ca.crt"
  client_cert_path = "../certificates/opensearch.crt"
  client_key_path  = "../certificates/opensearch.key"
}

provider "opensearch-ferlab" {
  endpoints   = "https://opensearch.ferlab.lan:9200"
  ca_cert     = "../certificates/opensearch-ca.crt"
  client_cert = "../certificates/opensearch.crt"
  client_key  = "../certificates/opensearch.key"
}
