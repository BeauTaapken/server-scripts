#!/bin/sh

CURDIR=$(dirname "$0")
source ${CURDIR}/.env

IP_FILE=${CURDIR}/.last_ip
CURRENT_IP=$(curl https://ipinfo.io/ip)
LAST_IP=$(cat "$IP_FILE" 2>/dev/null || echo "")

echo $TOKEN

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
    curl --location --request PUT "https://mijn.host/api/v2/domains/$DOMAIN/dns" \
    	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--header "API-Key: $TOKEN" \
	--data @- <<-JSON
	{
  	    "records": [
    		{ "type": "A", "name": "$DOMAIN.",   "value": "$CURRENT_IP", "ttl": 900 },
    		{ "type": "A", "name": "*.$DOMAIN.", "value": "$CURRENT_IP", "ttl": 900 }
  	    ]
	}
JSON
fi

if [ $? -eq 0 ]; then
    echo "$CURRENT_IP" > "$IP_FILE"
fi
