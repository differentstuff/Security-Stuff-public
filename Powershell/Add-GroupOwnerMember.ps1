function add-GroupOwnerMember{

# https://learn.microsoft.com/en-us/powershell/module/azuread/add-azureadgroupowner

<#

.SYNOPSIS
add $adminObjectId as group owner AND member to every Group specified by $listOfAllGroupNames


.DESCRIPTION
add $adminObjectId as group owner AND member to every Group specified by $listOfAllGroupNames

.PARAMETER adminObjectId
specific ID to add as Owner and Member

.EXAMPLE
add-GroupOwnerMember -listOfAllGroupNames $allGroups -adminObjectId $myAdminObjectId

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

            # add group owner
            $dump = Add-AzureADGroupOwner -ObjectId $groupInfoID -RefObjectId $adminObjectId -InformationAction SilentlyContinue

            # add group owner
            $dump2 = Add-AzureADGroupMember -ObjectId $groupInfoID -RefObjectId $adminObjectId -InformationAction SilentlyContinue

        }
        
        #do nothing
        catch{}

        }

}