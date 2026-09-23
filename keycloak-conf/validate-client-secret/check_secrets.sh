source auth.sh

PREVIOUS_SECRET=$(curl -s "http://keycloak.k8.ferlab.lan/admin/realms/test/clients/$KEYCLOAK_CID/client-secret/rotated" -H "$KEYCLOAK_AUTH" | jq -r .value)

echo "Previous secret is $PREVIOUS_SECRET"
echo "Trying to get a token with it..."

curl -X POST \
    "http://keycloak.k8.ferlab.lan/realms/test/protocol/openid-connect/token" \
    -u "test:$PREVIOUS_SECRET" -d grant_type=client_credentials

CURRENT_SECRET=$(curl -s -X GET "http://keycloak.k8.ferlab.lan/admin/realms/test/clients/$KEYCLOAK_CID/client-secret" -H "$KEYCLOAK_AUTH" | jq -r .value)

echo ""
echo "Current secret is $CURRENT_SECRET"
echo "Trying to get a token with it..."

curl -X POST \
    "http://keycloak.k8.ferlab.lan/realms/test/protocol/openid-connect/token" \
    -u "test:$CURRENT_SECRET" -d grant_type=client_credentials