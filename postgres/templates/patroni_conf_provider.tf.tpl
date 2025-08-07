provider "patroni" {
  servers = [
%{ for server in servers ~}
    {
        name = "${server.name}"
        address = "${server.ip}"
        port = 4443
    },
%{ endfor ~}
  ]
  ca_cert = "../shared/postgres_ca.crt"
  cert = "../shared/patroni_client.crt"
  key = "../shared/patroni_client.key"
}