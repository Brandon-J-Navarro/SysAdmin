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
    Name: Outage.psm1
    Author: Brandon J. Navarro
    Requires: Administrator Rights on the Server
    Major Release History:
        03/03/2023  - Initial Draft
        07/26/2023  - Current Release

.SYNOPSIS
    None

.DESCRIPTION
    Start-Outage will stop IIS web applications in the App Pool, and IIS web sites.
    Stop-Outage will start IIS web applications in the App Pool, and IIS web sites.

.PARAMETER WebApplication
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>
function Start-Outage {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0, Mandatory = $true)]
        [ValidateSet('[WEBAPP1]', '[WEBAPP2]', '[WEBAPP3]', IgnoreCase = $true)]$WebApplication
    )
    begin {
        Import-Module -Name IISAdministration, WebAdministration -Force
    }
    process {
        Switch ($WebApplication) {
            [WEBAPP1] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP1]' } | Select-Object name
                $website = Get-IISSite | Where-Object { $_.name -like '[WEBAPP1]' } | Select-Object name
                break;
            }
            [WEBAPP2] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP2]' } | Select-Object name
                $website += Get-IISSite | Where-Object { $_.name -like '[WEBAPP2]' } | Select-Object name
                break;
            }
            [WEBAPP3] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP3]' } | Select-Object name
                $website = Get-IISSite | Where-Object { $_.name -like '[WEBAPP3]' } | Select-Object name
            }
        }
        if ($null -eq $webapp) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('No Application to Stop!')
        }
        else {
            Foreach ($app in $webapp) {
                Stop-WebAppPool -Verbose -name $app.name
                Write-Host -ForegroundColor Yellow ('Stoping Application: {0}' -f $app.name)
            }
        }
        if ($null -eq $website) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('No Site to Stop!')
        }
        else {
            Foreach ($site in $website) {
                Stop-IISsite -Verbose -name $site.name -Confirm:$false
                Write-Host -ForegroundColor Yellow ('Stoping Site: {0}' -f $site.name) 
            }
        }
    }
    end {
        if ($null -eq $webapp -and $null -eq $website -and $null -eq $webtask) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('Nothing to Stop!')
        }
        else {
            $timestap = Get-Date -Format 'yyyy-MMM-dd HH:mm:sss UTCK'
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('Outage Started {0} for Web Application {1}' -f $timestap, $WebApplication)
        }
        Write-Host -ForegroundColor white ' '
    }
}


function Stop-Outage {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0, Mandatory = $true)]
        [ValidateSet('[WEBAPP1]', '[WEBAPP2]', '[WEBAPP3]', IgnoreCase = $true)]$WebApplication
    )
    begin {
        Import-Module -Name IISAdministration, WebAdministration -Force
    }
    process {
        Switch ($WebApplication) {
            [WEBAPP1] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP1]' } | Select-Object name
                $website = Get-IISSite | Where-Object { $_.name -like '[WEBAPP1]' } | Select-Object name
                break;
            }
            [WEBAPP2] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP2]' } | Select-Object name
                $website += Get-IISSite | Where-Object { $_.name -like '[WEBAPP2]' } | Select-Object name
                break;
            }
            [WEBAPP3] {
                $webapp = Get-IISAppPool | Where-Object { $_.name -like '[WEBAPP3]' } | Select-Object name
                $website = Get-IISSite | Where-Object { $_.name -like '[WEBAPP3]' } | Select-Object name
            }
        }
        if ($null -eq $webapp) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('No Application to Start!')
        }
        else {
            Foreach ($app in $webapp) {
                Start-WebAppPool -Verbose -name $app.name
                Write-Host -ForegroundColor Yellow ('Starting Application: {0}' -f $app.name)
            }
        }
        if ($null -eq $website) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('No Site to Start!')
        }
        else {
            Foreach ($site in $website) {
                Start-IISsite -Verbose -name $site.name
                Write-Host -ForegroundColor Yellow ('Starting Site: {0}' -f $site.name) 
            }
        }
    }
    end {
        if ($null -eq $webapp -and $null -eq $website -and $null -eq $webtask) {
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('Nothing to Start!')
        }
        else {
            $timestap = Get-Date -Format 'yyyy-MMM-dd HH:mm:sss UTCK'
            Write-Host ' '
            Write-Host -ForegroundColor Yellow ('Outage Stopped {0} for Web Application {1}' -f $timestap, $WebApplication)
        }
        Write-Host -ForegroundColor white ' '
    }
}

Export-ModuleMember -Function Start-Outage, Stop-Outage
