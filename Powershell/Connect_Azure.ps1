# Install-Module AzureAD
# Import-Module AzureAD

# Install-Module ExchangeOnlineManagement
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# Import-Module ExchangeOnlineManagement





#Basic Authentication
$credential = Get-Credential
Connect-AzureAD -Credential $credential

#MFA
Connect-AzureAD


#Disconnect
Disconnect-AzureAD -Confirm






# Create the password file (this should only be done once per computer)
(Get-Credential).Password | ConvertFrom-SecureString | Out-File ` “C:\temp\password.txt”

# Use the password file to authenticate
$user = “admin@myTenant.onmicrosoft.com”
$password = “C:\temp\password.txt”
$myCredential = New-Object –TypeName ` System.Management.Automation.PSCredential ` -ArgumentList $user, (Get-Content $password | ConvertTo-SecureString)

# Connect to Azure AD using stored credentials
Connect-AzureAD -Credential $myCredential | Out-Null

# Connect to Ex On using stored credentials
Connect-ExchangeOnline -Credential $myCredential | Out-Null

