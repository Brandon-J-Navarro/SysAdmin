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
    Name: ConnectRemoteHost.psm1
    Author: Brandon J. Navarro
    Requires: Administrator Rights on the Server
    Major Release History:
        02/10/2023  - Initial Draft Connect-RemoteVM Function
        03/06/2023  - Added Connect-RemotePS Function
        07/27/2023  - Current Release

.SYNOPSIS
    None

.DESCRIPTION
    Connect-RemoteVM is used for the "Menu" module
    Connect-RemotePS is used for the "RemoteWorkFlow" module

.PARAMETER None
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>
Function Connect-RemoteVM {
    [CmdletBinding()]
    param (
        [Parameter (Position=0,Mandatory = $true,ValueFromPipeline)]
        [array]$RemoteVM,
        [Parameter(Position=1,Mandatory = $true,ValueFromPipeline, HelpMessage = "Enter VM Credentials")]
        [pscredential]$Credential
    )
    begin {
        if (Get-PSSession | Where-Object ComputerName -EQ $RemoteVM) {
            Get-PSSession | Where-Object ComputerName -EQ $RemoteVM | Enter-PSSession
        }
        if ($Credential -isnot [PSCredential]) {
            $Credential = Get-Credential -Message "Enter User Credentials"
        }
    }
    process {
        New-PSSession -ComputerName $RemoteVM -Credential $Credential
        Get-PSSession | Where-Object ComputerName -EQ $RemoteVM | Enter-PSSession
    }
    end {
    }
}

Function Connect-RemotePS {
    [CmdletBinding()]
    param (
        [Parameter (Position=0,Mandatory = $true,ValueFromPipeline)]
        [array]$RemoteVM,
        [Parameter(Position=1,Mandatory = $true,ValueFromPipeline, HelpMessage = "Enter VM Credentials")]
        [pscredential]$Credential
    )
    begin {
        if ($Credential -isnot [PSCredential]) {
            $Credential = Get-Credential -Message "Enter User Credentials"
        }
    }
    process {
        if (Get-PSSession | Where-Object ComputerName -EQ $RemoteVM) {
            Write-Host -ForegroundColor Yellow ("Remote Session to {0} Already Exisits." -f $RemoteVM)
            Get-PSSession | Where-Object ComputerName -EQ $RemoteVM  | Format-Table Id,ComputerName,State,Availability
        }else{
            Write-Host -ForegroundColor Yellow ("Creating Remote Session to {0}." -f $RemoteVM)
            New-PSSession -ComputerName $RemoteVM -Credential $Credential
        }
    }
    end {
    }
}

Export-ModuleMember -Function Connect-RemoteVM,Connect-RemotePS
