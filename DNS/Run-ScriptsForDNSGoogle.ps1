function Run-ScriptsForDNSGoogle{

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
        [array]$alldomainNames
        )

    # import scripts into current scope
    . "$pwd\scripts\Get-SPFFromDomainViaGoogle.ps1"
    . "$pwd\scripts\Insert-Style.ps1"

    # get DNS info
    $SPFFromDomainViaGoogle = Get-SPFFromDomainViaGoogle -domainName $alldomainNames

    # sort DNS info
    $sortedObjects = $SPFFromDomainViaGoogle | sort Name, Type

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
        
        if(1 -ge ($alldomainNames.count)){

            # try export single domain
            $dump = $htmlTableStyled | Out-File "$pathToUse\Report-DNS-Google-$alldomainNames-$DateTime.htm"

            # confirm
            Write-Host "'Report-DNS-Google-$alldomainNames-$DateTime.htm'" -NoNewline -ForegroundColor Green
            Write-Host " has been written to Path " -NoNewline
            Write-Host "'$pathToUse'" -ForegroundColor Green

            }

        else{

            # try export multiple domains
            $dump = $htmlTableStyled | Out-File "$pathToUse\Report-DNS-Google-$DateTime.htm"

            # confirm
            Write-Host "'Report-DNS-Google-$DateTime.htm'" -NoNewline -ForegroundColor Green
            Write-Host " has been written to Path " -NoNewline
            Write-Host "'$pathToUse'" -ForegroundColor Green

            }

        }
    
    # save to tmp if no Access Rights
    catch [UnauthorizedAccessException]{
        
        # export to Temp
        $dump = $htmlTable2 | Out-File "$env:TEMP\Report-DNS-Google-$DateTime.htm"

        # not ok
        Write-Host "Could not write to current directory" -ForegroundColor DarkRed
        Write-Host "'Report-DNS-Google-$DateTime.htm'" -NoNewline -ForegroundColor Green
        Write-Host " has been written to Path " -NoNewline
        Write-Host "'$env:TEMP'" -ForegroundColor Yellow

        }
    
    # confirm
    finally{

        # ok
        # Write-Host "Report-File has been exported"

    }

}
