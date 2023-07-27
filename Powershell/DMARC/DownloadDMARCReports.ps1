<#
Released under MIT License

Copyright (c) 2023 Brandon J. Navarro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Version 202307

<#
.NOTES
    Name: DownloadDMARCReports.ps1
    Requires: 
    Major Release History:
        04/21/2023  - Initial Draft
        05/09/2023  - Initial Release
        07/27/2023  - Current Release

.SYNOPSIS
    None

.DESCRIPTION
    None

.PARAMETER None
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>

#Must be ran with Windows Powershell 5 and below
#To Run with Powershell 6 and above use 'Powershell.exe -File "File\Path\RetrieveDMARCReports.ps1"'

if ($PSVersionTable.PSVersion.Major -gt 5) {
    Write-Error "This command requires Windows PowerShell version 5.0."
    Write-Error ('To Run with Powershell 6 and above use "Powershell.exe -File File\Path\RetrieveDMARCReports.ps1"')
} else {
    #User Credentials that has Access to Shared Mailbox
    $Credential = Import-Clixml -Path [PATH\TO\SAVED\CREDENTIALS] # OR Get-Credntial
    if ($Credential -isnot [PSCredential]) {
        write-host "Enter Mailbox Credentials"
        $Credential = Get-Credential -Message "Enter Mailbox Credentials" -UserName "[USERNAME]"
    }
    #Shared Mailbox that the DMARC Reports are Sent to
    $sharedMailbox = "[MAILBOX]@[DOMAIN].com"
    #Url to query for EMail
    $url = "https://[EXCHANGEURL].com/api/v2.0/users/$sharedMailbox/mailFolders/inbox/messages"
    #Query filter to return UnRead EMail with attachments
    $queryuri = $url+"?`$select=Id&`$top=500&`$filter=IsRead eq false and HasAttachments eq true"
    #Query the API
    $messages = Invoke-RestMethod -Uri $queryuri -Credential $Credential -Method Get
    #Verify Inbox has UnRead Emails
    if ($messages.value.Count -ge 1){
        ## Loop through each results
        foreach ($message in $messages.value){
            # Get attachments and save to file system
            $query = $url + "/" + $message.Id + "/attachments"
            $attachments = Invoke-RestMethod $query -Credential $Credential
            # In case of multiple attachments in email
            foreach ($attachment in $attachments.value){
                $attachment.Name
                $Destination = "C:\DMARC\Source\" + $attachment.Name
                $Content = [System.Convert]::FromBase64String($attachment.ContentBytes)
                Set-Content -Path $Destination -Value $Content -Encoding Byte
            }
            # Mark as read
            $query = $url + "/" + $message.Id ;
            $body = @{
                IsRead = $True
            } | ConvertTo-Json;
            Invoke-RestMethod -uri $query -Body $body -ContentType "application/json" -Method PATCH -Credential $Credential
            # Move processed email to a subfolder
            $DestinationId = Invoke-RestMethod -Uri "https://[EXCHANGEURL].com/api/v2.0/Users('[MAILBOX]@[DOMAIN].com')/mailFolders/inbox/childFolders" -Credential $Credential
            $FolderId = $DestinationId.value | Where-Object { $_.DisplayName -eq '[FOLDERNAME]' } | Select-Object Id
            $query = $url + "/" + $message.Id + "/move";
            $body = @{
                DestinationId = $FolderId.Id
            } | ConvertTo-Json;
            Invoke-RestMethod -uri $query -Body $body -ContentType "application/json" -Method POST -Credential $Credential
        }
    }ELSE{
        Write-Host "No Messages to Process"
    }
}

