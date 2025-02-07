function Get-SPFFromOneDomain{

<#
.SYNOPSIS
Get DNS entries for given Domain.
uses https://dns.google/resolve

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
Get-SPFFromOneDomain -domainNames "mydomain.com","myseconddomain.com" -typeOfRequests "MX"

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

    # loop through all domains
    foreach($domainName in $domainNames){

        # initiate temp object
        $allObjects = [PSCustomObject]@{}
        
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

                        # if only one answer is found
                        if($newObject.Answer.data.count -eq 1){

                            # use only DKIM results
                            if($newObject.Answer.data.StartsWith("v=DKIM1")){

                                # redact answer
                                [string]$startOfString = $newObject.Answer.data[0][0..22] -join ""
                                [string]$middleOfString = "...[redacted]..."
                                [string]$endOfString = $newObject.Answer.data[0][-5..-1] -join ""
                                [string]$variableTemp = $startOfString + $middleOfString + $endOfString

                                }

                            }

                        # if multiple answers are found
                        if($newObject.Answer.data.count -gt 1){

                            # loop all answers
                            foreach($tempNewObject in $newObject.Answer.data){

                                # use only DKIM results
                                if($tempNewObject.StartsWith("v=DKIM1")){

                                    # redact answer
                                    [string]$startOfString = $tempNewObject[0..22] -join ""
                                    [string]$middleOfString = "...[redacted]..."
                                    [string]$endOfString = $tempNewObject[-5..-1] -join ""
                                    [string]$variableTemp = $startOfString + $middleOfString + $endOfString

                                    }

                                }

                            }

                        # set name
                        [string]$newName = "$domainName" + "-dkim-1"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                        }

                    # if not found
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dkim-1"
                        [string]$variableTemp = "No DKIM value found"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName
                        
                        }

                    # fetch DNS info selector2
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=selector2._domainkey.$domainName"

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        # if only one answer is found
                        if($newObject.Answer.data.count -eq 1){

                            # use only DKIM results
                            if($newObject.Answer.data.StartsWith("v=DKIM1")){

                                # redact answer
                                [string]$startOfString = $newObject.Answer.data[0][0..22] -join ""
                                [string]$middleOfString = "...[redacted]..."
                                [string]$endOfString = $newObject.Answer.data[0][-5..-1] -join ""
                                [string]$variableTemp = $startOfString + $middleOfString + $endOfString

                                }

                            }

                        # if multiple answers are found
                        if($newObject.Answer.data.count -gt 1){

                            # loop all answers
                            foreach($tempNewObject in $newObject.Answer.data){

                                # use only DKIM results
                                if($tempNewObject.StartsWith("v=DKIM1")){

                                    # redact answer
                                    [string]$startOfString = $tempNewObject[0..22] -join ""
                                    [string]$middleOfString = "...[redacted]..."
                                    [string]$endOfString = $tempNewObject[-5..-1] -join ""
                                    [string]$variableTemp = $startOfString + $middleOfString + $endOfString

                                    }

                                }

                            }

                        # add note
                        [string]$newName = "$domainName" + "-dkim-2"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                        }

                    # if no result
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dkim-2"
                        [string]$variableTemp = "No DKIM value found"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                        }
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

                            # add to object
                            Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName
                            
                            }

                        else{
                            
                            # add note
                            [string]$newName = "$domainName" + "-dmarc"
                            [string]$variableTemp = "Error in DNS Result"

                            # add to object
                            Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName
                            
                            }

                        }

                    # if not found
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-dmarc"
                        [string]$variableTemp = "No DMARC value found"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                        }
                   
                    }

                # TXT
                if($True){

                    # fetch DNS info (for other txt)
                    [PSCustomObject]$resultOfRequest = Invoke-WebRequest -Uri "https://dns.google/resolve?type=$typeOfRequest&name=$domainName"

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "0"){

                        # convert to object
                        [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                        [int]$countPerLine = 0

                        # do per line
                        foreach($variableTemp in $newObject.Answer.data){

                            # if = 0
                            if($newObject.Answer.data.Count -eq 0){
                                
                                    # add note
                                    [string]$newName = "$domainName" + "-txt"

                                    }

                            # if = 1
                            if($newObject.Answer.data.Count -eq 1){

                                # add note spf
                                if($variableTemp.StartsWith("v=spf")){ 
                            
                                    # add note
                                    [string]$newName = "$domainName" + "-spf"

                                    }
                                
                                # add note all other
                                if(!($variableTemp.StartsWith("v=spf"))){

                                    # add note
                                    [string]$newName = "$domainName" + "-txt-other"

                                    }

                                }

                            # if > 1
                            if($newObject.Answer.data.Count -gt 1){
                                
                                # count lines
                                $countPerLine += 1
                                
                                # add note spf
                                if($variableTemp.StartsWith("v=spf")){ 
                            
                                    # add note
                                    [string]$newName = "$domainName" + "-spf"

                                    }
                                
                                # add note all other plus count number
                                if(!($variableTemp.StartsWith("v=spf"))){

                                    # add note
                                    [string]$newName = "$domainName" + "-txt-other" + "-" + $countPerLine

                                    }

                                }

                            # add to object
                            Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                            }

                        }

                    # verify and add to object
                    if($resultOfRequest.Content[10] -eq "3"){

                        # add note
                        [string]$newName = "$domainName" + "-txt"

                        # add note
                        [string]$variableTemp = "No TXT value found"

                        # add to object
                        Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                        }

                        # sort out other txt and add to object
                        else{
                            
                            if($newObject.Answer.data.Count -gt 1){

                                $countPerLine += 1

                                # add note
                                [string]$newName = "$domainName" + "-txt-other" + "-" + $countPerLine

                                }

                                # 
                                else{

                                    [string]$newName = "$domainName" + "-txt-other"

                                    }

                            # add to object
                            Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                            }
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

                    # add to object
                    Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                    }

                                # verify and add to object
                if($resultOfRequest.Content[10] -eq "3"){

                    # convert to object
                    [PSCustomObject]$newObject = ConvertFrom-Json -InputObject $resultOfRequest.Content

                    # add note
                    [string]$newName = "$domainName" + "-mx"
                    [string]$variableTemp = "No MX value found"

                    # add to object
                    Add-Member -InputObject $allObjects -NotePropertyValue $variableTemp -NotePropertyName $newName

                    }


                }
                
            }
                
        # add temp object to final object
        $finalObjects += $allObjects
        }
        
    # return
    return $finalObjects

}