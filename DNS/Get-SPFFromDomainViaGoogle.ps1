function Get-SPFFromDomainViaGoogle{

<#
.SYNOPSIS
Get DNS entries for given Domain.
uses https://dns.google/resolve

.DESCRIPTION

.PARAMETER domainNames
input a single domain or a list (array) of multiple domains

.PARAMETER typeOfRequests (opt.)
a list of all kind of DNS requests to make (txt,mx,ns)

.PARAMETER getDKIM (opt.)
activate DKIM verification

.PARAMETER getDMARC (opt.)
activate DMARC verification

.EXAMPLE
Get-SPFFromDomainViaGoogle -domainNames "mydomain.com","myseconddomain.com"

.NOTES

#>

    param(
	    [Parameter(Mandatory=$True)]
        [array]$domainNames,
        [Parameter(Mandatory=$False)]
        [array]$typeOfRequests = ("mx","txt"),
        [Parameter(Mandatory=$False)]
        [switch]$getDKIM = $True,
        [Parameter(Mandatory=$False)]
        [switch]$getDMARC = $True
        )

    # initiate final object
    $finalObjects = [PSCustomObject]@()

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

        # initiate temp object
        $allObjects = [PSCustomObject]@()
        
        # loop through all requests
        foreach($typeOfRequest in $typeOfRequests){
    
            # TXT
            if($typeOfRequest -eq "txt"){

                # DKIM
                if($getDKIM -eq $True){

                    # fetch DNS info selector1
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=selector1._domainkey.$domainName"
                    
                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        # loop all answers
                        foreach($tempNewObject in $newObject.Answer.data){

                            # use only DKIM results
                            if($tempNewObject.StartsWith("v=DKIM1")){

                                # redact answer
                                [string]$startOfString = $tempNewObject[0..22] -join ""
                                [string]$middleOfString = "...[redacted]..."
                                [string]$endOfString = $tempNewObject[-5..-1] -join ""
                                [string]$variableTemp = $startOfString + $middleOfString + $endOfString

                                # set name
                                [string]$newName = "$domainName" + "-dkim-1"

                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash

                                # add to object
                                $tempObj.Name = $newName
                                $tempObj.Status = "OK"
                                $tempObj.Type = "DKIM"
                                $tempObj.Value = $variableTemp

                                # add to global object
                                $allObjects += $tempObj

                                }

                            }

                        }

                    # if not found
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dkim-1"
                        [string]$variableTemp = "No DKIM value found"

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # add to object
                        $tempObj.Name = $newName
                        $tempObj.Status = "NOT_OK"
                        $tempObj.Type = "DKIM"
                        $tempObj.Value = $variableTemp
                        $tempObj.ErrorMessage = "Domain or Value not found"

                        # add to global object
                        $allObjects += $tempObj
                        
                        }

                    # clear
                    Clear-Variable resultOfRequest,newObject,tempObj

                    # fetch DNS info selector2
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=selector2._domainkey.$domainName"

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        # loop all answers
                        foreach($tempNewObject in $newObject.Answer.data){

                            # use only DKIM results
                            if($tempNewObject.StartsWith("v=DKIM1")){

                                # redact answer
                                [string]$startOfString = $tempNewObject[0..22] -join ""
                                [string]$middleOfString = "...[redacted]..."
                                [string]$endOfString = $tempNewObject[-5..-1] -join ""
                                [string]$variableTemp = $startOfString + $middleOfString + $endOfString
                                
                                # add note
                                [string]$newName = "$domainName" + "-dkim-2"
                        
                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash
                                
                                # add to object
                                $tempObj.Name = $newName
                                $tempObj.Status = "OK"
                                $tempObj.Type = "DKIM"
                                $tempObj.Value = $variableTemp

                                # add to global object
                                $allObjects += $tempObj

                                }

                            }

                        }

                    # if no result
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dkim-2"
                        [string]$variableTemp = "No DKIM value found"

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # add to object
                        $tempObj.Name = $newName
                        $tempObj.Status = "NOT_OK"
                        $tempObj.Type = "DKIM"
                        $tempObj.Value = $variableTemp
                        $tempObj.ErrorMessage = "Domain or Value not found"

                        # add to object
                        $allObjects += $tempObj

                        }

                    # clear
                    Clear-Variable resultOfRequest,newObject,tempObj

                    }
                
                # DMARC
                if($getDMARC -eq $True){

                    # fetch DNS info dmarc
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=_dmarc.$domainName"
                    
                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        if($newObject.answer.Count -eq 1){
                            
                            # add note
                            [string]$newName = "$domainName" + "-dmarc"
                            [string]$variableTemp = $newObject.Answer.data

                            # create dummy
                            $tempObj = [PSCustomObject]$tempObjHash

                            # add to object
                            $tempObj.Name = $newName
                            $tempObj.Status = "OK"
                            $tempObj.Type = "DMARC"
                            $tempObj.Value = $variableTemp

                            # add to object
                            $allObjects += $tempObj
                            
                            }

                        else{
                            
                            # add note
                            [string]$newName = "$domainName" + "-dmarc"
                            [string]$variableTemp = "Error in DNS Result"

                            # create dummy
                            $tempObj = [PSCustomObject]$tempObjHash

                            # add to object
                            $tempObj.Name = $newName
                            $tempObj.Status = "OK"
                            $tempObj.Type = "DMARC"
                            $tempObj.Value = $variableTemp

                            # add to object
                            $allObjects += $tempObj
                            
                            }

                        }

                    # if not found
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dmarc"
                        [string]$variableTemp = "No DMARC value found"

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # add to object
                        $tempObj.Name = $newName
                        $tempObj.Status = "NOT_OK"
                        $tempObj.Type = "DMARC"
                        $tempObj.Value = $variableTemp
                        $tempObj.ErrorMessage = "Domain or Value not found"

                        # add to object
                        $allObjects += $tempObj

                        }
                   
                    # clear
                    Clear-Variable resultOfRequest,newObject,tempObj
                    
                    }

                # TXT
                if($True){

                    # fetch DNS info (for other txt)
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=$domainName"

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        # do per line
                        foreach($variableTemp in $newObject.Answer.data){

                            # add note spf
                            if($variableTemp.StartsWith("v=spf")){ 
                            
                                # add note
                                [string]$newName = "$domainName" + "-spf"

                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash

                                # add to object
                                $tempObj.Type = "SPF"

                                }
                                
                            # add note all other
                            if(-not($variableTemp.StartsWith("v=spf"))){

                                # add note
                                [string]$newName = "$domainName" + "-txt-other"

                                # create dummy
                                $tempObj = [PSCustomObject]$tempObjHash

                                # add to object
                                $tempObj.Type = "TXT"

                                }
                                                           
                            # add to object
                            $tempObj.Name = $newName
                            $tempObj.Status = "OK"
                            $tempObj.Value = $variableTemp

                            # add to object
                            $allObjects += $tempObj

                            }

                        }

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-txt"

                        # add note
                        [string]$variableTemp = "No TXT value found"

                        # create dummy
                        $tempObj = [PSCustomObject]$tempObjHash

                        # add to object
                        $tempObj.Name = $newName
                        $tempObj.Status = "NOT_OK"
                        $tempObj.Type = "TXT"
                        $tempObj.Value = $variableTemp
                        $tempObj.ErrorMessage = "Domain or Value not found"

                        # add to object
                        $allObjects += $tempObj

                        }
                    
                    # clear
                    Clear-Variable resultOfRequest,newObject,tempObj
                        
                    }

                }

            # MX
            if($typeOfRequest -eq "mx"){

                # fetch DNS info (for mx)
                [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=$domainName"

                # verify and add to object
                if($resultOfRequest.Content[10] -eq "0"){

                    # convert to object
                    [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                    # add note
                    [string]$newName = "$domainName" + "-mx"
                    [string]$variableTemp = $newObject.Answer.data

                    # create dummy
                    $tempObj = [PSCustomObject]$tempObjHash

                    # add to object
                    $tempObj.Name = $newName
                    $tempObj.Status = "OK"
                    $tempObj.Type = "MX"
                    $tempObj.Value = $variableTemp

                    # add to object
                    $allObjects += $tempObj

                    }

                # verify and add to object
                if($resultOfRequest.Content[10] -eq "3"){

                    # convert to object
                    [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                    # add note
                    [string]$newName = "$domainName" + "-mx"
                    [string]$variableTemp = "No MX value found"

                    # create dummy
                    $tempObj = [PSCustomObject]$tempObjHash

                    # add to object
                    $tempObj.Name = $newName
                    $tempObj.Status = "NOT_OK"
                    $tempObj.Type = "MX"
                    $tempObj.Value = $variableTemp
                    $tempObj.ErrorMessage = "Domain or Value not found"

                    # add to object
                    $allObjects += $tempObj

                    }

                # clear
                Clear-Variable resultOfRequest,newObject,tempObj
                
                }
                
            }
                
        # add temp object to final object
        $finalObjects += $allObjects

        }
        
    # return
    return $finalObjects

}
