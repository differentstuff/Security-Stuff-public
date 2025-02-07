function Get-AllDomainNames {
param()

    # get all domains
    [PSCustomObject]$allAZDomains = Get-AzureADDomain

    # extract names
    [array]$allAZDomainsNames = $allAZDomains.name

    # return results
    return $allAZDomainsNames      

        }