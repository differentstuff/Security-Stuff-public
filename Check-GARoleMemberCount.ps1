# uses MS Graph
function Check-GARoleMemberCount{

    # set description
    $checkName = "Global Administrators Count Status"
    $checkNameDescription = "Global Admins Count less than 5"
    $checkStatusPassed = "✔️"
    $checkStatusFailed = "❌"
    $checkStatusError = "No Data retreived"

    # set scope for MS Graph
    $scopesReadAll = @(

        "IdentityProvider.Read.All"
        "Directory.Read.All"
        "Group.Read.All"
        "Sites.Manage.All"
        "User.Read.All"

        )

    # create object
    $reportObject = [PsCustomObject]@{

        CheckName = $checkName
        Description = $checkNameDescription
        Status = ""
        Result = ""
        AdditionalData = ""

        }

    # connect to graph
    try{

        # connect to MS Graph
        $connectGraph = Connect-Graph -Scopes $scopesReadAll

        }
    
    catch {
        
        Write-Host "Could not connect to MS Graph" -ForegroundColor Red

        }

    # get info
    try{

        # get GA role ID
        [PSCustomObject]$globalAdminRoleID = Get-MgRoleManagementDirectoryRoleDefinition -Filter "(DisplayName eq 'Global Administrator')"

        # get all GA role members
        [array]$globalAdminRoleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id | Select-Object -ExpandProperty AdditionalProperties

        # sort GA role members
        [array]$checkAdditionalData = $globalAdminRoleMembers.userPrincipalName | Select-Object -Unique | Sort-Object

        # count GA role members
        if ($globalAdminRoleMembers.Count -ge 5) {

            # add info
            [string]$checkResult = "Microsoft recommends less than 5 users be granted the Global Administrator role. Please consider reducing the amount of Global Admins by assigning different roles to some of the users in the list"
            [string]$checkStatus = "$checkStatusFailed $($globalAdminRoleMembers.Count) Admins"

            }

        else {

            # add info
            [string]$checkResult = "You are meeting Microsoft's recommendation of having less than 5 users with the Global Administrator role"
            [string]$checkStatus = $checkStatusPassed

            }

        }

    catch {
        
        # return info
        Write-Host "Failed to run security check" -ForegroundColor Red
        Write-Host "Original error message: $($_.Exception.Message)`n" -ForegroundColor Red

        # add error to object
        $checkStatus = $checkStatusError
        $checkResult = "Security check failed"
        $checkAdditionalData = $_.Exception.Message

        }

    # disconnect from Graph
    finally{

        # disconnect
        $dump = Disconnect-Graph

        }

    # preparing results for object
    $reportObject.Status = $checkStatus
    $reportObject.Result = $checkResult
    $reportObject.AdditionalData = $checkAdditionalData

    # return object
    return $reportObject

}

# Check-GARoleMemberCount