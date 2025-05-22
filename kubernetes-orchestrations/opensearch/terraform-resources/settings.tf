resource "null_resource" "max_buckets_search_setting" {
  triggers = {
    value = local.max_buckets_search_setting
  }

  provisioner "local-exec" {
    command = <<EOT
      curl --silent --cert ${local.opensearch_client_cert_path} --key ${local.opensearch_client_key_path} --cacert ${local.opensearch_cacert_file} ${local.opensearch_url}/_cluster/settings \
        -X PUT \
        -H "Content-Type: application/json" \
        -d '{
              "persistent": {
                "search.max_buckets": ${local.max_buckets_search_setting}
              }
            }'
    EOT
  }
}
