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

# Version 202304

<#
.NOTES
Name: RemoteUptime.ps1
Requires: 
    Major Release History:
        02/10/2023  - Initial Draft
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

$objUptime  = [system.collections.generic.list[pscustomobject]]::new()

foreach ($RemoteHost in $MemberServer + $DomainController) {
    $Session = Get-PSSession | Where-Object { $_.ComputerName -eq $RemoteHost -and $_.state -eq 'Opened' -and $_.Availability -eq 'Available'}
    if($Session){
        $ComputerInfo = Invoke-Command -Session $Session -ScriptBlock{ 
            Get-ComputerInfo | Select-Object CsName,OsLastBootUpTime,LogonServer
        }
        $ComputerInfo | ForEach-Object{
            $Split  = $_ -split {$_ -eq ";" -or $_ -eq "=" -or $_ -eq "@{" -or $_ -eq "}"} 
            $objUptime.add([PSCustomObject]@{
                "ComputerName" = $Split[1]
                "LastBoot" =  $Split[3]
                "UptimeDays" = ((Get-Date) - ($_.OsLastBootUpTime)).days
                # "Logon Server" = $Split[5]
            })
        }
    }elseif (!$Session) {
        $not_available += $RemoteHost
        Write-host ("Remote Host(s) {0}, is not avaliable, please try again later" -f $not_available)
    }
}

$objUptime
