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
    Name: OpenRemoteSession.ps1
    Requires: Connect-RemotePS Module
    Major Release History:
        03/14/2023  - Initial Creation.
        07/27/2023  - Current Release.

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
#Domain Controller Array List
$DomainController = @(
    "[DC1HOSTNAME]",
    "[DC2HOSTNAME]"
)

#Member Server Array List
$MemberServer = @(
    "[MS1HOSTNAME]",
    "[MS2HOSTNAME]"
)

$DCCred = Import-Clixml -Path [FILEPATH\TO\SAVED\CREDENTIAL]
$MemberCred = Import-Clixml -Path [FILEPATH\TO\SAVED\CREDENTIAL]

#Gets Credentials for Domain Controllers
if ($DCCred -isnot [PSCredential]) {
    write-host "Enter Domain Controller Credentials"
    $DCCred = Get-Credential -Message "Enter Domain Controller Credentials" -UserName "[USERNAME]"
}

#Gets Credentials for Member Servers
if ($MemberCred -isnot [PSCredential]) {
    write-host "Enter Member Server Credentials"
    $MemberCred = Get-Credential -Message "Enter Member Server Credentials" -UserName "[USERNAME]"
}

#Opens PSSessions for Domain Controllers and MemberServers
foreach ($RemotePS in $MemberServer + $DomainController) {
    $Credential = if ($MemberServer -contains $RemotePS) { $MemberCred } else { $DCCred }
    Connect-RemotePS -RemoteVM $RemotePS -Credential $Credential -OutVariable $RemotePS.Split(".")[0]
    $OpenedSession = Get-PSSession | Where-Object { $_.ComputerName -eq $RemotePS -and $_.State -eq 'Opened' -and $_.Availability -eq 'Available'}
    if($OpenedSession) {
        $Session = $RemotePS.Split(".")[0]
        Write-host ("Remote Session Opened for {0} with Credential {1}" -f $Session,$Credential.UserName)
    }
}
