resource "tls_private_key" "admin_ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}