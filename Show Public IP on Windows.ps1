Invoke-WebRequest -Uri ifconfig.me -Method get -OutFile "C:\Temp\IP.txt" -PassThru | Out-String -Stream
Invoke-RestMethod -Uri ifconfig.me | Out-String -Stream | Write-Host
curl -Uri ifconfig.me | Write-Host