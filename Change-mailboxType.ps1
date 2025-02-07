function change-mailboxType{

<#
.SYNOPSIS
change Microsoft 365 (Exchange) Mailbox type into Regular, Shared or Room.
Can check type or change type.

.DESCRIPTION
Compatible with MFA.
Uses Connect-ExchangeOnline.
Has color in it.
You can run the script without parameters and enter everything later.

.PARAMETER mailboxToUse
append: -mailboxToUse "mailbox@domain.com"

.EXAMPLE
change-mailboxType

.NOTES
#>
    
    param(
        [Parameter(Mandatory=$False)]
        [string]$mailboxToUse
        )

    # connect
    Write-Host "Connecting to Exchange..."
    $dump = Connect-ExchangeOnline

    # set brakes off
    $stopIt = $False

    do {

        # write info
        Write-Host -ForegroundColor Cyan "------------------------------------------"
        Write-Host -ForegroundColor Cyan "How may I be of service today - my Master?"
        Write-Host -ForegroundColor Cyan "------------------------------------------"
        Write-Host
        Write-Host -ForegroundColor Red "    0 = Abort/Exit (or hit 'Enter')"
        Write-Host -ForegroundColor Green "    1 = convert to Regular Mailbox"
        Write-Host -ForegroundColor Yellow "    2 = convert to Shared Mailbox"
        Write-Host -ForegroundColor Gray "    3 = convert to Room Mailbox"
        Write-Host -ForegroundColor White "    4 = check Mailbox Type"
        Write-Host

        # ask user input
        $question1 = "Please choose a number"
        $userInput = Read-Host -Prompt $question1

        # ask for mailbox
        $question2 = "Please enter a mailbox"
        $mailboxToUse = Read-Host -Prompt $question2

        switch ($userInput) {
        
            # abort
            0 { $stopIt = $True ; break }

            # convert to Regular Mailbox
            1 { 

                # set
                $dump = Set-Mailbox $mailboxToUse -Type Regular 
                        
                # verify
                if("UserMailbox" -eq (Get-Mailbox $mailboxToUse).RecipientTypeDetails){

                    # confirm
                    Write-Host -ForegroundColor Green "I was successful!"

                    }

                else {
            
                    # confirm
                    Write-Host -ForegroundColor Magenta "That didn't work... " -NoNewline
                    Write-Host -ForegroundColor Magenta "It is still a" , ((Get-Mailbox $mailboxToUse).RecipientTypeDetails)

                    }

                }

            # convert to Shared Mailbox
            2 { 
            
                # set
                $dump = Set-Mailbox $mailboxToUse -Type Shared 
            
                # verify
                if("SharedMailbox" -eq (Get-Mailbox $mailboxToUse).RecipientTypeDetails){

                    # confirm
                    Write-Host -ForegroundColor Yellow "I was successful!"

                    }
            
                else {
            
                    # confirm
                    Write-Host -ForegroundColor Magenta "That didn't work... " -NoNewline
                    Write-Host -ForegroundColor Magenta "It is still a" , ((Get-Mailbox $mailboxToUse).RecipientTypeDetails)

                    }
                        
                }

            # convert to Room Mailbox
            3 { 
            
                # set
                $dump = Set-Mailbox $mailboxToUse -Type Room 
            
                # verify
                if("RoomMailbox" -eq (Get-Mailbox $mailboxToUse).RecipientTypeDetails){

                    # confirm
                    Write-Host -ForegroundColor Gray "I was successful!"

                    }

                else {
            
                    # confirm
                    Write-Host -ForegroundColor Magenta "That didn't work... " -NoNewline
                    Write-Host -ForegroundColor Magenta "It is still a" , ((Get-Mailbox $mailboxToUse).RecipientTypeDetails)

                    }

                }

            # check only
            4 {

                # request
                $resultType = (Get-Mailbox $mailboxToUse).RecipientTypeDetails

                # confirm
                Write-Host -ForegroundColor Green "Your mailbox is of type:" , $resultType
                Write-Host 

                }

            # default
            default { $stopIt = $True ; break }

            }

       } until ($True -eq $stopIt)

    # disconnect
    Write-Host -ForegroundColor Black -BackgroundColor White " Disconnecting ... "
    Disconnect-ExchangeOnline

    }

# change-mailboxType