#!/bin/sh
CURDIR=$(dirname "$0")
source ${CURDIR}/.env
curl "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$IP_ADDRESSi&verbose=true"
