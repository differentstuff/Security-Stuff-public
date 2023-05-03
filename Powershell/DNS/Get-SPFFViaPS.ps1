function Get-SPFFViaPS{

<#
.SYNOPSIS
Get DNS entries for given Domain.

.DESCRIPTION

.PARAMETER domainNames
input a single domain or a list (array) of multiple domains

.PARAMETER typeOfRequests
a list of all kind of DNS requests to make (txt,mx,ns)

.PARAMETER getDKIM
activate DKIM verification

.PARAMETER getDMARC
activate DMARC verification

.EXAMPLE
Get-SPFFViaPS -domainNames "mydomain.com","myseconddomain.com" -typeOfRequests "MX"

.NOTES

#>

    param(
	    [Parameter(Mandatory=$True)]
        [array]$domainNames,
        [Parameter(Mandatory=$False)]
        [switch]$getTXT = $True,
        [Parameter(Mandatory=$False)]
        [switch]$getMX = $True,
        [Parameter(Mandatory=$False)]
        [switch]$getDKIM = $True,
        [Parameter(Mandatory=$False)]
        [switch]$getDMARC = $True
        )

    # initiate final object
    $finalObjects = [PSCustomObject]@()

    # Set List Trigger to False ($tempObjList)
    [bool]$tempObjListFilled = $False

    # create values for dummy
    $tempObjHash = [ordered]@{
        Status = ""
        Name = "" 
        Type = ""
        Value = ""
        ErrorMessage = ""
        }

    # loop through all domains
    foreach($domainName in $domainNames){

        # initiate object
        $tempResults = [PSCustomObject]@()
    
        # dkim
        if($True -eq $getDKIM){

            # resolve DNS selector 1
            try {
                    
                # request DNS
                $dnsRecord1 = Resolve-DnsName -Name "selector1._domainkey.$domainName" -Type TXT -ErrorAction Stop

                # create dummy
                $tempObj = [PSCustomObject]$tempObjHash

                # count results = 0
                if(0 -eq $dnsRecord1.count){
                        
                    # transfer data
                    $tempObj.Name = $domainName
                    $tempObj.Type = "DKIM1"
                    $tempObj.Value = "No DKIM value found"
                    $tempObj.Status = "OK"
                    $tempObj.ErrorMessage = ""
                        
                    }

                # count results = 1
                if(0 -lt $dnsRecord1.count){

                    # loop all results to search DKIM
                    foreach($countNumber in 0..($dnsRecord1.count-1)){

                        # only if strings are present
                        if($dnsRecord1.Item($countNumber).Strings){
                        
                            # put value to object
                            [Array]$strings = ($dnsRecord1.Item($countNumber)).Strings

                                }

                        }

                            # clean value (to verify it afterwards)
                            $tempValue = $null

                            # if proper DKIM value is found
                            if($strings.startswith("v=DKIM1")){

                                # abbreviate answer
                                [string]$startOfString = $strings[0..22] -join ""
                                [string]$middleOfString = "...[abbreviated]..."
                                [string]$endOfString = $strings[-5..-1] -join ""
                                [string]$tempValue = $startOfString + $middleOfString + $endOfString

                                # transfer data
                                $tempObj.Name = $domainName
                                $tempObj.Type = "DKIM1"
                                $tempObj.Value = $tempValue
                                $tempObj.Status = "OK"
                                $tempObj.ErrorMessage = ""
                        
                                }

                            # if still no DKIM has been found
                            if($null -eq $tempValue){

                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash

                                # transfer data
                                $tempObj.Name = $domainName
                                $tempObj.Type = "DKIM1"
                                $tempObj.Value = "No DKIM found"
                                $tempObj.Status = "OK"
                                $tempObj.ErrorMessage = $_.Exception.Message
                                }

                    }

                }

            # on error create note
            catch {

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # transfer data
                        $tempObj.Name = $domainName
                        $tempObj.Type = "DKIM1"
                        $tempObj.Value = "No DKIM found"
                        $tempObj.Status = "NOT_OK"
                        $tempObj.ErrorMessage = $_.Exception.Message
                    
                        }

            # append results to tempResults
            finally{
                    
                        # append to Results
                        $tempResults += $tempObj

                        # clean up to avoid duplication
                        Clear-Variable tempObj

                        }
                   
            # resolve DNS selector 2
            try {
                    
                # request DNS
                $dnsRecord1 = Resolve-DnsName -Name "selector2._domainkey.$domainName" -Type TXT -ErrorAction Stop

                # create dummy
                $tempObj = [PSCustomObject]$tempObjHash

                # count results = 0
                if(0 -eq $dnsRecord1.count){
                        
                    # transfer data
                    $tempObj.Name = $domainName
                    $tempObj.Type = "DKIM2"
                    $tempObj.Value = "No DKIM value found"
                    $tempObj.Status = "OK"
                    $tempObj.ErrorMessage = ""
                        
                    }

                # count results = 1
                if(0 -lt $dnsRecord1.count){

                    # loop all results to search DKIM
                    foreach($countNumber in 0..($dnsRecord1.count-1)){

                        # only if strings are present
                        if($dnsRecord1.Item($countNumber).Strings){
                        
                            # put value to object
                            [Array]$strings = ($dnsRecord1.Item($countNumber)).Strings

                                }

                        }

                            # clean value (to verify it afterwards)
                            $tempValue = $null

                            # if proper DKIM value is found
                            if($strings.startswith("v=DKIM1")){

                                # abbreviate answer
                                [string]$startOfString = $strings[0..22] -join ""
                                [string]$middleOfString = "...[abbreviated]..."
                                [string]$endOfString = $strings[-5..-1] -join ""
                                [string]$tempValue = $startOfString + $middleOfString + $endOfString

                                # transfer data
                                $tempObj.Name = $domainName
                                $tempObj.Type = "DKIM2"
                                $tempObj.Value = $tempValue
                                $tempObj.Status = "OK"
                                $tempObj.ErrorMessage = ""
                        
                                }

                            # if still no DKIM has been found
                            if($null -eq $tempValue){

                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash

                                # transfer data
                                $tempObj.Name = $domainName
                                $tempObj.Type = "DKIM2"
                                $tempObj.Value = "No DKIM found"
                                $tempObj.Status = "OK"
                                $tempObj.ErrorMessage = $_.Exception.Message
                                }

                    }

                }

            # on error create note
            catch {

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # transfer data
                        $tempObj.Name = $domainName
                        $tempObj.Type = "DKIM2"
                        $tempObj.Value = "No DKIM found"
                        $tempObj.Status = "NOT_OK"
                        $tempObj.ErrorMessage = $_.Exception.Message
                    
                        }

            # append results to tempResults
            finally{
                    
                        # append to Results
                        $tempResults += $tempObj

                        # clean up to avoid duplication
                        Clear-Variable tempObj

                        }

            }

        # dmarc
        if($True -eq $getDMARC){

                    # resolve DNS and create put into temp object
                    try {
                    
                        # request DNS
                        $dnsRecord = Resolve-DnsName -Name "_dmarc.$domainName" -Type TXT -ErrorAction Stop

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # count results = 0
                        if($dnsRecord.count -eq 0){
                        
                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "DMARC"
                            $tempObj.Value = "No DMARC value found"
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }

                        # count results = 1
                        if($dnsRecord.count -eq 1){
                        
                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "DMARC"
                            $tempObj.Value = Out-String -InputObject $dnsRecord.Strings
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }
                            
                        # count results > 1
                        if($dnsRecord.count -gt 1){

                            # loop
                            foreach($dnsRecordTemp in $dnsRecord){

                                # create dummy
                                $tempObj2 = [PSCustomObject]$tempObjHash

                                # transfer data
                                $tempObj2.Name = $dnsRecordTemp.Name
                                $tempObj2.Type = "DMARC"
                                $tempObj2.Value = Out-String -InputObject $dnsRecordTemp.Strings
                                $tempObj2.Status = "OK"
                                $tempObj2.ErrorMessage = ""

                                # add to object
                                $tempObj += $tempObj2

                                }

                            }

                        }

                    # on error
                    catch {

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # transfer data
                        $tempObj.Name = $domainName
                        $tempObj.Type = "DMARC"
                        $tempObj.Value = "No DMARC found"
                        $tempObj.Status = "NOT_OK"
                        $tempObj.ErrorMessage = $_.Exception.Message
                    
                        }

                    # do your job
                    finally{
                    
                        # append to Results
                        $tempResults += $tempObj

                        # clean up to avoid duplication
                        Clear-Variable tempObj

                        }
                   
                    }

        # txt
        if($True -eq $getTXT){

                    # create dummy
                    $tempObj = [PSCustomObject]$tempObjHash

                    # resolve DNS and create put into temp object
                    try {
                    
                        # request DNS
                        $dnsRecord = Resolve-DnsName -Name $domainName -Type $typeOfRequest -ErrorAction Stop | Where-Object { $_.Type -eq $typeOfRequest }


                        # count results = 0
                        if($dnsRecord.count -eq 0){
                        
                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "TXT"
                            $tempObj.Value = "No TXT value found"
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }

                        # count results = 1
                        if($dnsRecord.count -eq 1){
                        
                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "TXT"
                            $tempObj.Value = Out-String -InputObject $dnsRecord.Strings
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }
                            
                        # count results > 1
                        if($dnsRecord.count -gt 1){

                            # create list
                            $tempObjList = [PSCustomObject]@()

                            # loop
                            foreach($dnsRecordTemp in $dnsRecord){

                                # create dummy
                                $tempObj2 = [PSCustomObject]$tempObjHash

                                # transfer data
                                $tempObj2.Name = $dnsRecordTemp.Name
                                $tempObj2.Type = "TXT"
                                $tempObj2.Value = Out-String -InputObject $dnsRecordTemp.Strings
                                $tempObj2.Status = "OK"
                                $tempObj2.ErrorMessage = ""

                                # add to object
                                $tempObjList += $tempObj2

                                # create Trigger
                                $tempObjListFilled = $True

                                }

                            }

                        }

                    # on error
                    catch {

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # transfer data
                        $tempObj.Name = $domainName
                        $tempObj.Type = "TXT"
                        $tempObj.Value = "No TXT value found"
                        $tempObj.Status = "NOT_OK"
                        $tempObj.ErrorMessage = $_.Exception.Message
                    
                        }

                    # do your job
                    finally{
                    
                        # check if List is Present False
                        if($tempObjListFilled -eq $False){

                            # append to Results
                            $tempResults += $tempObj

                            }

                        # check if List is Present True
                        if($tempObjListFilled -eq $True){
                            
                            # append to Results
                            $tempResults += $tempObjList

                            # deactivate Trigger
                            $tempObjListFilled = $False

                            }

                        # clean up to avoid duplication
                        Clear-Variable tempObj -ErrorAction SilentlyContinue
                        Clear-Variable tempObjList -ErrorAction SilentlyContinue

                        }

                    }

        # mx
        if($True -eq $getMX){

                if($True){

                    # create dummy
                    $tempObj = [PSCustomObject]$tempObjHash

                    # resolve DNS and create put into temp object
                    try {
                    
                        # request DNS
                        $dnsRecord = Resolve-DnsName -Name $domainName -Type $typeOfRequest -ErrorAction Stop | Where-Object { $_.Type -eq $typeOfRequest }

                        # count results
                        if($dnsRecord.count -eq 0){

                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "MX"
                            $tempObj.Value = "No MX value found"
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }

                        # count results
                        if($dnsRecord.count -eq 1){

                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "MX"
                            $tempObj.Value = Out-String -InputObject $dnsRecord.NameExchange
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""
                        
                            }

                        # count results
                        if($dnsRecord.count -gt 1){

                            # transfer data
                            $tempObj.Name = $domainName
                            $tempObj.Type = "MX"
                            $tempObj.Value = "multiple MX values found"
                            $tempObj.Status = "OK"
                            $tempObj.ErrorMessage = ""

                            }

                        }

                    # on error
                    catch {

                        # transfer data
                        $tempObj.Name = $domainName
                        $tempObj.Type = "MX"
                        $tempObj.Value = "No MX value found"
                        $tempObj.Status = "NOT_OK"
                        $tempObj.ErrorMessage = $_.Exception.Message
                    
                        }

                    # do your job
                    finally{
                    
                        # append to Results
                        $tempResults += $tempObj
                        
                        # clean up to avoid duplication
                        Clear-Variable tempObj

                        }

                    }            

                }

        # append to final object
        $finalObjects += $tempResults

        }

    # return
    return $finalObjects

}