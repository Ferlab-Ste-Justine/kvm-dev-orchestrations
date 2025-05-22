locals {
  opensearch_url              = "https://opensearch.ferlab.lan:9200"
  opensearch_cacert_file      = "../certificates/opensearch-ca.crt"
  opensearch_client_cert_path = "../certificates/opensearch.crt"
  opensearch_client_key_path  = "../certificates/opensearch.key"

  max_buckets_search_setting = "100000"  # set to a string with the value "null" to remove the setting
}
