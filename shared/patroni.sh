if [ -n "$3" ]; then
  curl --cacert postgres_ca.crt --cert patroni_client.crt --key patroni_client.key -X $1 -d "$3" "https://postgres.ferlab.lan:4443$2"
else
  curl --cacert postgres_ca.crt --cert patroni_client.crt --key patroni_client.key -X $1 "https://postgres.ferlab.lan:4443$2"
fi