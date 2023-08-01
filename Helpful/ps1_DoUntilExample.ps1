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

# Version 202308

<#
.NOTES
	Name: DoUntilExample.ps1
	Requires: 
    Major Release History:
        08/01/2023  - Initial Creation.

#>

# Define Computer Name 
$MemberServer = "[FQDN]"

# Gets Credential for Member Server
$MemberCred = Import-Clixml -Path [C:\CREDENTIAL\PATH\MemberCred.xml]
if ($MemberCred -isnot [PSCredential]) {
    write-host "Enter Member Server Credentials"
    $MemberCred = Get-Credential -Message "Enter Member Server Credentials" -UserName "[USERNAME]@[DOMAIN]"
}

# Opens PSSessions for MemberServer
New-PSSession -ComputerName $MemberServer -Credential $MemberCred

# Gets PSSession for MemberServer
$Session = Get-PSSession | Where-Object ComputerName -eq $MemberServer

# Starts Job 
$Job = Invoke-Command -Session $Session -ScriptBlock {
    # Connects to Exchange Server to test the receiveing back job for authentication in the first do unitl loop
    Import-Module 'RemoteExchange.ps1'; Connect-ExchangeServer -ServerFqdn $MemberServer -ClientApplication:ManagementShell -UserName [DOMAIN]\[USERNAME]
    # Script writes output "Hello World" and starts sleep to test the second do unit loop
    pwsh.exe -command "test.ps1" 
} -AsJob

# Waits for job to return Failed, Completed or Blocked (Authentication Needed)
do {
    Write-Output $Job
    Write-Host "Connecting"
    Start-Sleep -Seconds 10
} until (
    $Job.State -eq "Completed" -or $Job.State -eq "Failed" -or $Job.State -eq "Blocked"
)
if ($Job.State -eq "Failed") {
    Write-Host "Job Failed"
    # Do Something
}elseif ($Job.State -eq "Completed"){
    Write-Host "Job Complete"
    # Do Something
}elseif ($Job.State -eq "Blocked"){
    Write-Host "Please Athenticate"
    Receive-Job $Job
}

# Waits for job to return Failed, or Completed
do {
    Write-Output $Job
    Write-Host "Processing"
    Start-Sleep -Seconds 10
} until ($Job.State -eq "Completed" -or $Job.State -eq "Failed")
if ($Job.State -eq "Failed") {
    Write-Host "Failed"
    # Do Something
}elseif($Job.State -eq "Completed"){
    Write-Host "Done"
    # Do Something
}

