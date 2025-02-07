function Run-ScriptsForDNS{
<#
.SYNOPSIS
1. get DNS entries for given Domain.
2. export results as html

.DESCRIPTION

.PARAMETER domainNames
input a single domain or a list (array) of multiple domains

.EXAMPLE
Run-ScriptsForDNS -domainNames "mydomain.com"

.NOTES

#>

    param(
	    [Parameter(Mandatory=$True)]
        [array]$domainNames
        )

    # import scripts into current scope
    . "$pwd\Get-SPFFromDomainViaPS.ps1"
    . "$pwd\Insert-Style.ps1"

    # get DNS info
    $SPFFromDomainViaPS = Get-SPFFromDomainViaPS -domainName $alldomainNames

    # sort DNS info
    $sortedObjects = $SPFFromDomainViaPS | sort Name, Type

    # formatting
    [string]$DateTimeDot = Get-Date -Format dd.MM.yyyy
    [string]$DateTime = Get-Date -Format ddMMyyyy
    [string]$titleToUse = "DNS-Report " + $DateTimeDot
    [string]$pathToUse = "$pwd\Reports"

    # sort and create html (and add title)
    [PSCustomObject]$htmlTable = $sortedObjects | ConvertTo-Html -As Table -Title $titleToUse

    # insert styling
    [PSCustomObject]$htmlTableStyled = Insert-Style -htmlTable $htmlTable

    # test if path exists
    if(-not (test-path $pathToUse)){
        
        # create path in currect dir
        $dump = New-Item -Path $pathToUse -ItemType Directory -Force

        }

    # export table
    try{
        
        # try export
        $dump = $htmlTableStyled | Out-File "$pathToUse\Report-DNS-$DateTime.htm"

        # confirm
        Write-Host "'Report-DNS-$DateTime.htm'" -NoNewline -ForegroundColor Green
        Write-Host " has been written to Path " -NoNewline
        Write-Host "'$pathToUse'" -ForegroundColor Green
        
        }
    
    # save to tmp if no Access Rights
    catch [UnauthorizedAccessException]{
        
        # export to Temp
        $dump = $htmlTable2 | Out-File "$env:TEMP\Report-DNS-$DateTime.htm"

        # not ok
        Write-Host "Could not write to current directory" -ForegroundColor DarkRed
        Write-Host "'Report-DNS-$DateTime.htm'" -NoNewline -ForegroundColor Green
        Write-Host " has been written to Path " -NoNewline
        Write-Host "'$env:TEMP'" -ForegroundColor Yellow

        }
    
    # confirm
    finally{

        # ok
        Write-Host "Report-File has been exported"

    }

}

# [array]$alldomainNames = "mydomain1.com","mydomain2.com"
# Run-ScriptsForDNS -domainNames $alldomainNames
