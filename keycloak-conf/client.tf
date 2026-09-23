resource "keycloak_openid_client" "test" {
  realm_id    = keycloak_realm.test.id
  client_id   = "test"
  name        = "test"
  access_type = "CONFIDENTIAL"
  enabled     = true

  service_accounts_enabled     = true
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false

  lifecycle {
    ignore_changes = [client_secret]
  }
}

resource "keycloak_openid_audience_protocol_mapper" "test_audience" {
  realm_id                 = keycloak_realm.test.id
  client_id                = keycloak_openid_client.test.id
  name                     = "test-audience"
  included_custom_audience = "test"
  add_to_id_token          = false
  add_to_access_token      = true
}