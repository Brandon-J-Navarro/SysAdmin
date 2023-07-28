#https://docs.abuseipdb.com/#introduction
#https://www.abuseipdb.com/bulk-report
#https://www.abuseipdb.com/categories

curl.exe https://api.abuseipdb.com/api/v2/bulk-report \
  -F csv=@report.csv \
  -H "Key: YOUR_OWN_API_KEY" \
  -H "Accept: application/json" \
  > output.json
