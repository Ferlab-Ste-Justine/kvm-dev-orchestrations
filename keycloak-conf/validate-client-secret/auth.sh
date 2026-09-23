ADMIN_TOKEN=$(curl -s -X POST "http://keycloak.k8.ferlab.lan/realms/master/protocol/openid-connect/token" \
  -d grant_type=password -d client_id=admin-cli \
  -d username="admin" -d password="admin" | jq -r .access_token)
export KEYCLOAK_AUTH="Authorization: Bearer $ADMIN_TOKEN"
export KEYCLOAK_CID=$(curl -s "http://keycloak.k8.ferlab.lan/admin/realms/test/clients?clientId=test" -H "$KEYCLOAK_AUTH" | jq -r '.[0].id')

