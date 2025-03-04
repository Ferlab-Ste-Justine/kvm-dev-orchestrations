resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = var.common_name
    country = ""
    locality = ""
    organization = ""
    organizational_unit = ""
    postal_code = ""
    province = ""
    serial_number = ""
    street_address = []
  }

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
  ]

  is_ca_certificate = true
}