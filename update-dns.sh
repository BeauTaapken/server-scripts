#!/bin/sh

CURDIR=$(dirname "$0")
source ${CURDIR}/.env

IP_FILE=${CURDIR}/.last_ip
CURRENT_IP=$(curl https://ipinfo.io/ip)
LAST_IP=$(cat "$IP_FILE" 2>/dev/null || echo "")

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
    echo "$CURRENT_IP" > "$IP_FILE"
    # curl --location --request PATCH "https://mijn.host/api/v2/domains/$DOMAIN/dns" \
    #	--header 'Accept: application/json' \
#	--header 'Content-Type: application/json' \
#	--header 'API-Key: "$API_KEY"' \
#	--data-raw '{
#    	    "record": {
#        	"type": "A",
#        	"name": "$DOMAIN",
#        	"value": "$CURRENT_IP",
#        	"ttl": 900
#    	    }
#	}'
    curl "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$IP_ADDRESSi&verbose=true"
fi
