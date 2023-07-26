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
    Name: BanScript.ps1
    Requires: Administrator rights on the target server.
    Major Release History:
        01/27/2023 - Initial Release.
        07/26/2023 - Current Release.

.SYNOPSIS
    Parses HTTPERR logs and adds IPs within the logs to Firewall rules.

.DESCRIPTION
    Parses HTTPERR logs and adds IPs within the logs to Firewall rules.

.PARAMETER None
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>
Function init() {
    Remove-Module FirewallModule -Force -Verbose
    Remove-Module LogParser -Force -Verbose
    Import-Module LogParser -Force -Verbose
    Import-Module FirewallModule -Force -Verbose

    #HttpErrLogEntries
    $httperrlogs = Get-ChildItem -LiteralPath 'C:\Windows\System32\LogFiles\HTTPERR\' | Where-Object { $_.Name -like '*.log' }
    if ($httperrlogs) {
        foreach ( $log in $httperrlogs ) { 
            Move-Item -Path $log.FullName -Destination 'C:\Temp\Log_temp\HTTPERR\Pre-Process\' -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
    $preprocess = Get-ChildItem -LiteralPath 'C:\Temp\Log_temp\HTTPERR\Pre-Process'
    if ($preprocess) {
        $preprocess | ForEach-Object {
            $objHttpErrLogData = Get-HttpErrLogs -HttpErrLogPath $_
            # if ($objHttpErrLogData) {
            #     $objHttpErrLogData | Export-Csv -Path ('C:\Logs\HTTPERR\HTTPERR-Logs.{0}.csv' -f ($_.name -replace '.log')) -NoTypeInformation
            # }
            #HttpErrBAN
            $httpErrResults = $objHttpErrLogData | Where-Object { $_.ClientIp -notcontains '[IPADDRESS]' -and $_.ClientIp -notmatch '^(192\.168\.1\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$' -and $_.HTTPERR -eq $true }
            if ($httpErrResults) {
                Write-Output 'Invoking firewall rule on HTTPERRLog Hit'
                $httpfwban = Invoke-FirewallRule -RuleId 2 -IpAddresses $httpErrResults.ClientIp -ErrorVariable ErrorHTTPERR
                Write-Output $httpfwban
                $httpErrResults | Export-Csv -Path ('C:\Logs\HTTPERR\HTTPERR-Logs.{0}.BanLog.{1}.csv' -f ($_.name -replace '.log'), (Get-CustomLogTimestamp)) -NoTypeInformation
                if ($ErrorHTTPERR) {
                    $ErrorHTTPERR | Out-File -Path ('C:\Logs\ProcessErrors.{0}.txt' -f (Get-CustomLogTimestamp))
                    exit
                }
            }
            Move-Item -LiteralPath $_.FullName -Destination 'C:\Temp\Log_temp\HTTPERR\Post-Process\'
        }
    }

    #IISLogEntries
    $iislogs = Get-ChildItem -LiteralPath 'C:\inetpub\logs\LogFiles\' | Where-Object { $_.Name -like '*.log' -and $_.LastWriteTime -lt (Get-Date).Date }
    if ($iislogs) {
        foreach ( $log in $iislogs ) { 
            Move-Item -Path $log.FullName -Destination 'C:\Temp\Log_temp\IIS\Pre-Process\'
        }
    }
    $preprocess = Get-ChildItem -LiteralPath 'C:\Temp\Log_temp\IIS\Pre-Process'
    if ($preprocess) {
        $preprocess | ForEach-Object {
            $objIISLogData = Get-IISLogs -IISLogPath $_
            # $objIISLogData | Export-Csv -Path ('C:\Logs\IIS\IIS-Logs.{0}.csv' -f ($_.name -replace '.log')) -NoTypeInformation
            Move-Item -LiteralPath $_.FullName -Destination 'C:\Temp\Log_temp\IIS\Post-Process\'
        }
    }
}
$init = init | Out-File ('C:\Logs\BanScript.{0}.txt' -f (Get-CustomLogTimestamp))
