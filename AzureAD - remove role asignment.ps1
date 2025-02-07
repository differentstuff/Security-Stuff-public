#Connect
Connect-AzAccount

# parameters
$SignInName = "admin@tenant.onmicrosoft.com"
$subscriptionID = "88888888-0000-4172-b2c0-c22d9e37f0f2"


#Search assignment
Get-AzRoleAssignment | where {$_.RoleDefinitionName -eq "User Access Administrator" -and $_.SignInName -eq $SignInName -and $_.Scope -eq "/"}

#remove assignment
$roleassignment = Get-AzRoleAssignment -SignInName $SignInName -RoleDefinitionName "User Access Administrator" -Scope "/subscriptions/$subscriptionID/"
Remove-AzRoleAssignment -InputObject $roleassignment