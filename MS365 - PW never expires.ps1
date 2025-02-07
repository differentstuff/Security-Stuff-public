Exit 0

# Connect
#Basic Authentication
$credential = Get-Credential
Connect-AzureAD -Credential $credential
#with MFA
Connect-AzureAD
#Disconnect
Disconnect-AzureAD -Confirm


# Check PW expire STATUS for all users
Get-AzureADUser -All $true | Select-Object UserprincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}}
# Set PW expire OFF for all users
Get-AzureADUser -All $true | Set-AzureADUser -PasswordPolicies DisablePasswordExpiration
# Set PW expire ON for all users
Get-AzureADUser -All $true | Set-AzureADUser -PasswordPolicies None


# Set PW expire ON for specific user
#get username
$Username = Read-Host "Please enter Username."
#check status
Get-AzureADUser -ObjectId $Username | Select-Object UserprincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}}
#ask for change
$activate = Read-Host "Should PW-never-expire be set to 'Yes', 'No' or 'Exit'?"
Switch ($activate){
    Yes {Set-AzureADUser -ObjectId $Username -PasswordPolicies DisablePasswordExpiration} #Set a password to never expire
    No {Set-AzureADUser -ObjectId $Username -PasswordPolicies None} #Set a password to expire
    Exit {Write-Host "No change was done"}
}


# Set PW expire OFF for specific user
#check status
Get-AzureADUser -All $true | Select-Object UserprincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}}
#ask for change
$activate = Read-Host "Should PW-never-expire be set to 'Yes', 'No' or 'Exit'?"
Switch ($activate){
    Yes {Set-AzureADUser -All $true -PasswordPolicies DisablePasswordExpiration}
    No {Set-AzureADUser -All $true -PasswordPolicies None}
    Exit {Write-Host "No change was done"}
}