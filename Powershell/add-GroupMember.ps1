function add-GroupMember{

# https://learn.microsoft.com/en-us/powershell/module/azuread/add-azureadgroupmember

<#

.SYNOPSIS
add $adminObjectId as group member to every Group specified by $listOfAllGroupNames

.DESCRIPTION
add $adminObjectId as group member to every Group specified by $listOfAllGroupNames

.PARAMETER adminObjectId
specific ID to add as member

.EXAMPLE
add-GroupMember -listOfAllGroupNames $allGroups -adminObjectId $myAdminObjectId

.NOTES

#>

    param(
        [Parameter(Mandatory=$True)]
        [array]$listOfAllGroupNames,
	    [Parameter(Mandatory=$True)]
        [string]$adminObjectId
        )

    # get all groups
    $allGroupsInfo = Get-AzureADGroup -All:$true

    # loop all groups
    foreach($groupToDo in $listOfAllGroupNames){

        # get correct Group by Name
        $groupInfo = $allGroupsInfo | Where-Object -Property DisplayName -EQ -Value $groupToDo

        # get correct ID
        $groupInfoID = $groupInfo.ObjectId

        try{

            # add group member
            $dump = Add-AzureADGroupMember -ObjectId $groupInfoID -RefObjectId $adminObjectId -InformationAction SilentlyContinue
            
        }
        
        #do nothing
        catch{}

        }

}