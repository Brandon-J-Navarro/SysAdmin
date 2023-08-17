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
    Name: RemoteExchangeManagementShell.ps1
    Requires: 
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
    Invoke-Command -Session (Get-PSSession | Where-Object ComputerName -eq "[HOSTNAME]") -ScriptBlock {
        $env:PSModulePath = $env:PSModulePath+';C:\Program Files\PowerShell\7\Modules\'
        Import-Module '[MODULE\FILE\PATH]'; [FUNCTION]
        pwsh.exe -command "[SCRIPT\FILE\PATH]"
    } -AsJob

#>
Invoke-Command -Session (Get-PSSession | Where-Object ComputerName -eq "[EXCHANGEHOSTNAME]") -ScriptBlock {
    $env:PSModulePath = $env:PSModulePath+';C:\Program Files\PowerShell\7\Modules\;C:\Program Files\Microsoft\Exchange Server\V15\bin\'
    Import-Module 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -ServerFqdn [EXCHANGEHOSTNAME] -ClientApplication:ManagementShell -UserName [DOMAIN\USERNAME]
    Import-Module "ExhangeTransportLogs.ps1"
} -AsJob
