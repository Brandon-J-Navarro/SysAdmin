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
    Name: FirewallModule.psm1
    Requires: Administrator rights on the target server.
    Major Release History:
        01/27/2023 - Initial Release.
        07/26/2023 - Current Release.

.SYNOPSIS
	Checks target servers for last boot time, current up time in days, and logon server.

.DESCRIPTION
	This script checks for last boot time, current up time in days, and logon server.
    It also checks to see if the current powershell session has credentials loaded,
    if not it will prompt you for your crednetials, and applies the different credentials 
    to the appropriate servers. It will cather all the information and out a table of information.

.PARAMETER None
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>

Function Get-FirewallRuleScope {
    [CmdletBinding()]
    Param
    (
        # Parameter help description
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [string]$RuleName
    )
    BEGIN {

    }
    PROCESS {
        $firewallRule = Get-NetFirewallRule -DisplayName $RuleName | Get-NetFirewallAddressFilter
        $currentIpAddresses = $firewallRule.RemoteIP;
    }
    END {
        Return $currentIpAddresses
    }
}

Function Update-FirewallRuleScope {
    [CmdletBinding()]
    Param
    (
        # Parameter help description
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [string]$FirewallRule,
        [Parameter(Position = 1, ValueFromPipeline, Mandatory)]
        [psobject]$IpAddresses

    )
    PROCESS {
        Set-NetFirewallRule -DisplayName $FirewallRule -RemoteAddress $IpAddresses
    }
    END {
        $result = Get-FirewallRuleScope -RuleName $FirewallRule
        return $result
    }
}

Function Merge-IpAddress {
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [psobject]$CurrentIpAddresses,
        [Parameter(Position = 1, ValueFromPipeline, Mandatory)]
        [psobject]$NewIpAddresses
    )
    BEGIN {
        $allIpAddresses = @();
    }
    PROCESS {
        $CurrentIpAddresses | ForEach-Object {
            $allIpAddresses += $_
        }
        $NewIpAddresses | ForEach-Object {
            $allIpAddresses += $_
        }
        $allIpAddresses = $allIpAddresses  | Sort-Object | Get-Unique
    }
    END {
        return $allIpAddresses
    }

}
Function Get-Difference {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [int]$CurrentCount,
        [Parameter(Position = 1, ValueFromPipeline, Mandatory)]
        [int]$OldCount
    )
    PROCESS {
        Return $CurrentCount - $OldCount
    }
}
function Get-CustomTimestamp {
    Return (Get-Date -Format 'yyyy-MMM-dd HH:mm:sss UTCK')
}
function Get-CustomLogTimestamp {
    Return (Get-Date -Format 'yyyyMMdd-HHmmsss')
}
Function Invoke-FirewallRule {
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [string]$RuleId,
        [Parameter(Position = 1, ValueFromPipeline, Mandatory)]
        [psobject]$IpAddresses
    )
    BEGIN {
        $OriginalForeground = $host.ui.RawUI.ForegroundColor
        $currentIpAddresses = @()
        $host.ui.RawUI.ForegroundColor = "Magenta"
        Write-Output ('Action Beginning: {0}' -f (Get-CustomTimestamp))
        $host.ui.RawUI.ForegroundColor = $OriginalForeground

    }
    PROCESS {
        $HTTPERRfirewallRuleName = 'Block All Ports By IP Address (SRC: HTTPERR)'
        Write-Output ('Retrieving currently blocked IP addresses from {0}' -f $HTTPERRfirewallRuleName)
        $currentIpAddresses = Get-FirewallRuleScope -RuleName $HTTPERRfirewallRuleName
        Write-Output 'Merging new IP addresses with currently blocked IP addresses'
        $mergedIpAddresses = Merge-IpAddress -CurrentIpAddresses $currentIpAddresses -NewIpAddresses $IpAddresses
        if ($mergedIpAddresses.Count -eq $currentIpAddresses.Count) {
            $host.ui.RawUI.ForegroundColor = "Green"
            Write-Output 'No IP addresses to block'
            $host.ui.RawUI.ForegroundColor = $OriginalForeground
            break
        }
        else {
            $Count = $IpAddresses | Sort-Object | Get-Unique | Where-Object { $currentIpAddresses -notcontains $_ }
            Write-Output ('Updating Firewall Rule: {0} with {1} IP Addresses' -f $HTTPERRfirewallRuleName, $count.Count)
            Update-FirewallRuleScope -FirewallRule $HTTPERRfirewallRuleName -IpAddresses $mergedIpAddresses | Out-Null
            $finalCount = Get-FirewallRuleScope -RuleName $HTTPERRfirewallRuleName
            $host.ui.RawUI.ForegroundColor = "Red"
            Write-Output ('IP addresses in log files:         {0}' -f $ipAddresses.Count)
            $host.ui.RawUI.ForegroundColor = "Yellow"
            Write-Output ('Currently blocked IP addresses:      {0}' -f $currentIpAddresses.Count)
            $host.ui.RawUI.ForegroundColor = "Blue"
            Write-Output ('Total New IP addresses added:            {0}' -f $Count.Count)
            $host.ui.RawUI.ForegroundColor = "Green"
            Write-Output ('Final count of blocked IP addresses: {0}' -f $finalCount.Count)
            $host.ui.RawUI.ForegroundColor = $OriginalForeground
        }
    }
    END {
        $host.ui.RawUI.ForegroundColor = "Magenta"
        Write-Output ('Action Complete: {0}' -f (Get-CustomTimestamp))
        $host.ui.RawUI.ForegroundColor = $OriginalForeground

    }
}
Export-ModuleMember -Function Invoke-FirewallRule, Get-CustomTimestamp, Get-CustomLogTimestamp
