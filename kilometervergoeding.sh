CURDIR=$(dirname "$0")
source ${CURDIR}/.env

FILE_LOCATION=${CURDIR}
FILE_NAME=Gereden-KMs

soffice --convert-to 'pdf:draw_pdf_Export:{"PageRange":{"type":"string","value":"1"}}' ${FILE_LOCATION}/${FILE_NAME}.ods --outdir ${CURDIR}

soffice --convert-to csv ${FILE_LOCATION}/${FILE_NAME}.ods --outdir ${CURDIR}

TOTAL_PRICE=$(awk -F',' 'NR > 1 && $5 != "" {print $5}' ${CURDIR}/${FILE_NAME}.csv)

rm ${CURDIR}/${FILE_NAME}.csv

# NOTE: why last month? this code is run in a cronjob after the month is finished but uploading driven KM's of last month
LAST_MONTH=$(date +%m-%Y --date="last month")

EXPENSE_ID=$(curl -v --request POST \
  --url "https://bonus.giantfox.nl/api/expenses" \
  -H "Authorization: Bearer ${API_KEY}"\
  -H 'Content-Type: multipart/form-data' \
  -F "description=Kilometers ${LAST_MONTH}" \
  -F "amount=${TOTAL_PRICE}" \
  -F "company=Tango" \
  -F "receipt=@${CURDIR}/${FILE_NAME}.pdf" \
  -F "date=$(date +%d-%m-%Y)" | jq '.id')

rm ${CURDIR}/${FILE_NAME}.pdf

curl --request POST \
  --url "https://bonus.giantfox.nl/api/expenses/${EXPENSE_ID}/submit" \
  -H "Authorization: Bearer ${API_KEY}"
