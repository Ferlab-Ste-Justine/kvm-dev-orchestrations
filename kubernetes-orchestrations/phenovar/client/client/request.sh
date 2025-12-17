TOKEN=$(cat /opt/phenovar-token/token)
TOKEN="${TOKEN%%*[[:blank:]]}"

curl -X POST \
     -H "accept: application/json" -H "Authorization: Token $TOKEN" -H "Content-Type: application/json" \
     --data "@/opt/work/body.json" \
     http://phenovar-server:8000/phenovar3/rest_api/dxtablegenerator/generate/