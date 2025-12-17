TOKEN=$(cat /opt/phenovar-token/token)
TOKEN="${TOKEN%%*[[:blank:]]}"

curl -H "Authorization: Token $TOKEN" \
     http://phenovar-server:8000/phenovar3/rest_api/dxtablegenerator/check-status/?task_id=$1