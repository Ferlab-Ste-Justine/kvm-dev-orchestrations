resource "keycloak_realm" "test" {
  realm                          = "test"
  display_name                   = "Test"
  enabled                        = true
  registration_email_as_username = true
  login_with_email_allowed       = true
}

resource "keycloak_realm_client_policy_profile" "test_profile" {
  name     = "test"
  realm_id = keycloak_realm.test.id

  executor {
    name = "secret-rotation"

    configuration = {
      expiration-period = "604800",
      rotated-expiration-period = "43200",
      remaining-rotation-period = "43200"
    }
  }
}

resource "keycloak_realm_client_policy_profile_policy" "test_profile_policy" {
  name        = "test"
  realm_id    = keycloak_realm.test.id
  description = "Apply secret rotation to all openid clients"
  profiles = [
    keycloak_realm_client_policy_profile.test_profile.name
  ]

  condition {
    name = "client-type"
    configuration = {
      "protocol" = "openid-connect"
    }
  }
}