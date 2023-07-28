#https://github.com/ssllabs/ssllabs-scan/blob/master/ssllabs-api-docs-v3.md

"https://www.ssllabs.com/ssltest/analyze.html?d=[DOMAIN.COM]&hideResults=on"


$url = "https://api.ssllabs.com/api/v3/analyze?host=www.ssllabs.com"

$url = "https://api.ssllabs.com/api/v3/analyze?host=[DOMAIN.COM]&publish=off"
$response = Invoke-WebRequest -Method POST -Uri $url
$results = ConvertFrom-Json $response.Content
$results

$url = "https://api.ssllabs.com/api/v3/analyze?host=[DOMAIN.COM]&publish=off&startNew=on&all=on"


$url = "https://api.ssllabs.com/api/v3/info"
$response = Invoke-WebRequest -Method GET -Uri $url
