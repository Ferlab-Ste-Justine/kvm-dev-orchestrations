provider "opensearch" {
  endpoints   = "https://opensearch.ferlab.lan:9200"
  ca_cert     = "../certificates/opensearch-ca.crt"
  client_cert = "../certificates/opensearch.crt"
  client_key  = "../certificates/opensearch.key"
}
