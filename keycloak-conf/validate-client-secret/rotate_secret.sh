source auth.sh
curl -s -X POST "http://keycloak.k8.ferlab.lan/admin/realms/test/clients/$KEYCLOAK_CID/client-secret" -H "$KEYCLOAK_AUTH" | jq -r .value