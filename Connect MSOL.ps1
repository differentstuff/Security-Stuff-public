$credential = Get-Credential
Connect-MsolService -Credential $credential
Get-MsolUser

Get-MsolUser | ft DisplayName,UserPrincipalName,UsageLocation