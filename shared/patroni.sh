curl --cacert postgres_ca.crt --cert patroni_client.crt --key patroni_client.key -X $1 "https://postgres.ferlab.lan:4443$2"