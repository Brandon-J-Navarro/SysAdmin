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
Name: RemoteUpdates.ps1
Requires: 
    Major Release History:
        03/29/2023  - Initial Draft
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

$objUpdates  = [system.collections.generic.list[pscustomobject]]::new()

foreach ($RemoteHost in $MemberServer + $DomainController) {
    $Session = Get-PSSession | Where-Object { $_.ComputerName -eq $RemoteHost -and $_.State -eq 'Opened' -and $_.Availability -eq 'Available'}
    if($Session){
        $PendingUpdates = Invoke-Command -Session $Session -ScriptBlock{ 
            $Updates = New-Object -ComObject Microsoft.Update.Session
            $Searcher = $Updates.CreateUpdateSearcher()
            $GetUpdates = $Searcher.Search("IsInstalled=0")
            $GetUpdates.Updates | Select-Object -Property Title,PSComputerName
        }
        $PendingUpdates | Group-Object -Property PSComputerName | ForEach-Object { 
            $objUpdates.add([PSCustomObject]@{
                'ComputerName' = $_.Group[0].PSComputerName
                'UpdateName' = ($_.Group.Title | Where-Object {$_ -ne $null}) -join "`r`n" | Out-String
            })
        }
    }elseif (!$Session) {
        $not_available += $RemoteHost
        Write-host ("Remote Host(s) {0}, is not avaliable, please try again later." -f $not_available)
    }
}

$objUpdates | Format-List
