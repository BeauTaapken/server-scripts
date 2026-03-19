CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${CURDIR}/.env

response=$(curl -D - -X POST \
  -H 'Content-Type: application/json' \
  -H 'Referer: https://my.youfone.nl/inloggen' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
  https://my.youfone.nl/api/prov/authentication/login)

SECURITY_KEY=$(echo "$response" | grep -i '^securitykey:' | awk '{print $2}')
CUSTOMER_ID=$(echo "$response" | grep -o '"customerId": *[0-9]*' | grep -o '[0-9]*')

INVOICES=$(curl -D ${CURDIR}/headers.txt -X POST \
	-H 'Content-Type: application/json' \
	-H 'Referer: https://my.youfone.nl/facturen/sim-only' \
	-H "SecurityKey: $SECURITY_KEY" \
	-d "{\"customerId\":$CUSTOMER_ID}" \
	https://my.youfone.nl/api/prov/Invoice/GetInvoices)

SECURITY_KEY=$(grep -i '^securitykey:' ${CURDIR}/headers.txt | awk '{print $2}')

rm ${CURDIR}/headers.txt

LATEST_INVOICE=$(echo $INVOICES | jq -r '.invoices' | jq -r 'sort_by(.date | split("T")[0]) | reverse | .[0]')

INVOICE_NUMBER=$(echo "$LATEST_INVOICE" | jq -r '.number')
INVOICE_DATE=$(echo "$LATEST_INVOICE" | jq -r '.date')
INVOICE_PRICE=$(echo "$LATEST_INVOICE" | jq -r '.amount')

if [[ "$(date -d "$INVOICE_DATE" +%Y)" != "$(date +%Y)" || "$(date -d "$INVOICE_DATE" +%m)" != "$(date +%m)" ]]; then
  echo "Found an invoice, not of this month though"
  exit 1
fi

INVOICE_FILE=invoice-${INVOICE_DATE}.pdf

INVOICE_DATA=$(curl -X POST \
	-H 'Content-Type: application/json' \
	-H 'Referer: https://my.youfone.nl/facturen/sim-only' \
	-H "SecurityKey: $SECURITY_KEY" \
	-d "{\"customerId\":$CUSTOMER_ID,\"invoiceNumber\":\"$INVOICE_NUMBER\"}" \
	https://my.youfone.nl/api/prov/Pdf/GetInvoice \
	| jq -r '.content' \
	| base64 -d > ${CURDIR}/${INVOICE_FILE})

qpdf --decrypt ${CURDIR}/${INVOICE_FILE} --replace-input

FORMATTED_DATE=$(date -d "${INVOICE_DATE}" +%F)

EXPENSE_ID=$(curl -X POST \
  --url "https://bonus.giantfox.nl/api/expenses" \
  -H "Authorization: Bearer ${API_KEY}"\
  -H 'Content-Type: multipart/form-data' \
  -F "description=Simpel Invoice ${INVOICE_DATE}" \
  -F "amount=${INVOICE_PRICE}" \
  -F "company=Simpel" \
  -F "receipt=@${CURDIR}/${INVOICE_FILE}" \
  -F "date=${FORMATTED_DATE}" | jq '.id')

rm -f ${CURDIR}/invoice*.pdf

curl --request POST \
  --url "https://bonus.giantfox.nl/api/expenses/${EXPENSE_ID}/submit" \
  -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1
