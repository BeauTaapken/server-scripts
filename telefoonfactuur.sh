CURDIR=$(dirname "$0")
source ${CURDIR}/.env

COOKIES=$(curl -c - --request POST \
  --url https://api.simpel.nl/login \
  --header 'Content-Type: application/json' \
  -d '{
	"username": "'$USERNAME'",
	"password": "'$PASSWORD'"
}')

INVOICE=$(curl -c ./temp.cookie --cookie <(echo "$COOKIES") --request GET \
  --url https://mijn.simpel.nl/api/invoice/latest?sid=$SID \
  --header 'Content-Type: application/json' | jq '.[0]')

COOKIE=$(cat ${CURDIR}/temp.cookie)

rm ${CURDIR}/temp.cookie

INVOICE_ID=$(echo "$INVOICE" | jq -r '.number')
INVOICE_DATE=$(echo "$INVOICE" | jq -r '.invoiceDate')
INVOICE_PRICE=$(echo "$INVOICE" | jq -r '.amount + .extraAmount')

if [[ "$(date -d "$INVOICE_DATE" +%Y)" != "$(date +%Y)" || "$(date -d "$INVOICE_DATE" +%m)" != "$(date +%m)" ]]; then
  echo "Found an invoice, not of this month though"
  exit 1
fi

INVOICE_FILE=invoice-${INVOICE_DATE}.pdf

curl --cookie <(echo "$COOKIE") \
  "https://mijn.simpel.nl/facturen/${INVOICE_ID}/pdf?sid=${SID}" > ${CURDIR}/${INVOICE_FILE}

#TODO: upload to BonusTool with api (set fields correctly and stuff)

FORMATTED_DATE=$(date -d "${INVOICE_DATE}" +%F)


EXPENSE_ID=$(curl --request POST \
  --url "https://bonus.giantfox.nl/api/expenses" \
  -H "Authorization: Bearer ${API_KEY}"\
  -H 'Content-Type: multipart/form-data' \
  -F "description=Simpel Invoice ${INVOICE_DATE}" \
  -F "amount=${INVOICE_PRICE}" \
  -F "company=Simpel" \
  -F "receipt=@${CURDIR}/${INVOICE_FILE}" \
  -F "date=${FORMATTED_DATE}" | jq '.id')

rm ./invoice-*

curl --request POST \
  --url "https://bonus.giantfox.nl/api/expenses/${EXPENSE_ID}/submit" \
  -H "Authorization: Bearer ${API_KEY}"

