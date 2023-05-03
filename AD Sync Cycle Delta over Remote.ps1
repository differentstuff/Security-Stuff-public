$creds = "admin@domain.com"
$targetIP = "10.50.0.10"

Invoke-Command -ComputerName $targetIP -ScriptBlock { start-adsyncsynccycle -policy delta } -credential $creds