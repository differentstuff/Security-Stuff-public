#Prerequisites
#Prerequisites
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
$credential = get-credential
Import-Module MSOnline

#Connect to Exchange Portal
Connect-MsolService -Credential $credential
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession

#Disconnect from Exchange Portal
Remove-PSSession $ExchangeSession







# --- Export all SMTP to csv ---
Get-Mailbox | Select-Object DisplayName,@{Name=”EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -LIKE “SMTP:*”}}} | Sort | Export-Csv C:\Temp\email-aliases.csv
Write-Host "Check : C:\Temp\email-aliases.csv" -BackgroundColor Green