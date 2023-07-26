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
    Name: LogParser.psm1
    Requires: Administrator rights on the target server.
    Major Release History:
                ?   - Initial Release.
        07/26/2023  - Current Release.

.SYNOPSIS
    Parses various logs 

.DESCRIPTION
    Parses various logs

.PARAMETER None
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>
function Get-IISLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$IISLogPath
    )
    begin {
        $Path = 'C:\inetpub\logs\LogFiles\'
        $logFiles = Get-ChildItem -Path $IISLogPath -Filter '*.log'
        Write-Output 'Log Count:'$logfiles.count
        $logfileCounter = 1
        $currentEntry = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    process {
        $logFiles | ForEach-Object {
            $timestamp_log = Get-CustomTimestamp
            $functionRunInfo = ('[{3}] Parsing log entries in {2} ({0} of {1})' -f $logfileCounter, $logFiles.Count, $_.Name, $timestamp_log)
            Write-Output $functionRunInfo

            $logName = $_.Name
            Get-Content $_.FullName | ForEach-Object {
                if ($_ -match '^(\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2}:\d{2})(.*)$') {
                    $EventDate = [datetime]::ParseExact($matches[1], 'yyyy-MM-dd HH:mm:ss', $null) -split ' '
                    $Message = $matches[2] -split ' '
                    $currentEntry.add([PSCustomObject]@{
                            'EventDate'      = $EventDate[0]
                            'EventTime'      = $EventDate[1]
                            'TimeStamp'      = $matches[1]
                            'FilePath'       = $Path
                            'FileName'       = $logName
                            'SiteName'       = $Message[1]
                            'Hostname'       = $Message[2]
                            'HostIp'         = $Message[3]
                            'HttpMethod'     = $Message[4]
                            'Endpoint'       = $Message[5]
                            'Query'          = $Message[6]
                            'LocalPort'      = $Message[7]
                            'Username'       = $Message[8]
                            'ClientIp'       = $Message[9]
                            'HttpVerion'     = $Message[10]
                            'Agent'          = $Message[11]
                            'ClientCookie'   = $Message[12]
                            'URL'            = $Message[13]
                            'WebSite'        = $Message[14]
                            'HttpStatusCode' = $Message[15]
                            'Substatus'      = $Message[16]
                            'Win32Status'    = $Message[17]
                            'SourceBytes'    = $Message[18]
                            'ClientBytes'    = $Message[19]
                            'ResponseTime'   = $Message[20]
                            'SourceIp'       = $Message[21]
                            'Connection'     = $Message[22]
                            'Warning'        = $Message[23]
                            'HTTPConnection' = $Message[24]
                            'Authorization'  = $Message[25]
                        })
                }
            }
            $logfileCounter++
        }
    }
    end {
        $currentEntry | Export-Csv -Path ('C:\Logs\IIS\IIS-Logs.{0}.csv' -f ($logName -replace '.log')) -NoTypeInformation
        return $currentEntry
    }
}

function Get-HttpErrLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$HttpErrLogPath
    )
    begin {
        $Path = 'C:\Windows\System32\LogFiles\HTTPERR'
        $Patterns = '.php', '.conf', 'wp-content', 'sleep', 'cgi-bin', '.cgi', 'DispForm', 'GponForm', 'chmod', 'redlion', 'viewlsts.aspx', 'wget', 'boaform', 'ip.ws.', '.env', 'exec', '.config'
        $logFiles = Get-ChildItem -Path $HttpErrLogPath -Filter '*.log'
        Write-Output 'Log Count:'$logfiles.count
        $logfileCounter = 1
        $currentEntry = [System.Collections.Generic.List[PSCustomObject]]::new()
        # }
        # process {
        $logFiles | ForEach-Object {
            $timestamp_log = Get-CustomTimestamp
            $functionRunInfo = ('[{3}] Parsing log entries in {2} ({0} of {1})' -f $logfileCounter, $logFiles.Count, $_.Name, $timestamp_log)
            Write-Output $functionRunInfo

            $logName = $_.Name
            Get-Content $_.FullName | ForEach-Object {
                if ($_ -match '^(\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2}:\d{2})(.*)$') {
                    $EventDate = [datetime]::ParseExact($matches[1], 'yyyy-MM-dd HH:mm:ss', $null) -split ' '
                    $Message = $matches[2] -split ' '
                    $PatternMatch = $Message[7] | Select-String -Pattern $Patterns -SimpleMatch
                    $currentEntry.add([PSCustomObject]@{
                            'EventDate'      = $EventDate[0]
                            'EventTime'      = $EventDate[1]
                            'TimeStamp'      = $matches[1]
                            'FilePath'       = $Path
                            'FileName'       = $logName
                            'ClientIp'       = $Message[1]
                            'ClientPort'     = $Message[1]
                            'LocalIp'        = $Message[2]
                            'LocalPort'      = $Message[4]
                            'HttpProtocol'   = $Message[5]
                            'HttpMethod'     = $Message[6]
                            'HTTPERR'        = if ($Message[7] | Select-String -Pattern $Patterns -SimpleMatch) {
                                "$true"
                            }
                            else {
                                "$false"
                            }
                            'PatternMatch'   = if ($PatternMatch) {
                                $PatternMatch.Pattern
                            }
                            else {
                                '-'
                            }
                            'UriRequest'     = $Message[7]
                            'HttpStatusCode' = $Message[9]
                            'HttpStatusText' = $Message[11]
                        })
                }
            }
            $logfileCounter++
        }
    }
    end {
        $currentEntry | Export-Csv -Path ('C:\Logs\HTTPERR\HTTPERR-Logs.{0}.csv' -f ($logName -replace '.log')) -NoTypeInformation
        return $currentEntry
    }
}

Export-ModuleMember -Function Get-HttpErrLogs, Get-IISLogs
