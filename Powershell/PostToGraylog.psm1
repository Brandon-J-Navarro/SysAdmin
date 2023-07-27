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
    Name: PostToGraylog.psm1
    Requires: Powershell Package Provider Nuget, Powershell Module PSGELF
    Major Release History:
        05/22/2023  - Initial Creation.
        07/27/2023- Current Release.

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

    $IIS = Get-ChildItem 'C:\Logs\IIS'
    foreach($file in $IIS){Update-Graylog -FilePath $file.FullName -Log IIS}

    $HTTPERR = Get-ChildItem 'C:\Logs\HTTPERR' | where {$_.name -notlike "*.BanLog.*"}
    foreach($file in $HTTPERR ){Update-Graylog -FilePath $file.FullName -Log HTTPERR}

    $EMTL = Get-ChildItem 'C:\Logs\Exchange'
    foreach($file in $EMTL ){Update-EMTLGraylog -Path  $file.FullName}

#>
function Update-GrayLog {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0, Mandatory)]
        [string]$FilePath,
        [Parameter (Position = 1, Mandatory)]
        [ValidateSet('HTTPERR', 'IIS', IgnoreCase = $true)]
        [string]$Log,
        [Parameter(Position = 2)]
        [string]$ShortMessage,
        [Parameter (Position = 3)]
        [string]$FullMessage,
        [Parameter(Position = 4)]
        [string]$LogSource,
        [Parameter(Position = 5)]
        [string]$Hostname,
        [Parameter(Position = 6)]
        [string]$Server,
        [Parameter(Position = 7)]
        [string]$Port
    )
    begin {
        $CSV = Import-Csv $FilePath
        $Today = Get-Date -Format MM/dd/yyyy
        if (!($Sever)) {
            $Server = '127.0.0.1'
        }
        if (!($Port)) {
            $Port = '12201'
        }
        if (!($Hostname)) {
            $Hostname = '[WEBSERVERHOSTNAME]'
        }
    }
    process {
        foreach ($Object in $CSV) {
            switch ($log) {
                HTTPERR {
                    $Time = $Object.TimeStamp
                    $LogData = @{
                        EventDate      = $Object.EventDate
                        EventTime      = $Object.EventTime
                        TimeStamp      = $Object.TimeStamp
                        FilePath       = $Object.FilePath
                        FileName       = $Object.FileName
                        IpAddress      = $Object.ClientIp
                        LocalPort      = $Object.LocalPort
                        HttpProtocol   = $Object.HttpProtocol
                        HttpMethod     = $Object.HttpMethod
                        HTTPERR        = $Object.HTTPERR
                        PatternMatch   = $Object.PatternMatch
                        UriRequest     = $Object.UriRequest
                        HttpStatusCode = $Object.HttpStatusCode
                        HttpStatusText = $Object.HttpStatusText
                    }
                    if (!($ShortMessage)) {
                        $ShortMessage = 'HTTPERR'
                    }
                    if (!($FullMessage)) {
                        $FullMessage = $Object.EventDate + " HTTPERR Logs Imported: $Today"
                    }
                    if (!($LogSource)) {
                        $LogSource = "$Hostname HTTPERR Logs"
                    }
                    break;
                }
                IIS {
                    $Time = $Object.TimeStamp
                    $LogData = @{
                        EventDate      = $Object.EventDate
                        EventTime      = $Object.EventTime
                        TimeStamp      = $Object.TimeStamp
                        FilePath       = $Object.FilePath
                        FileName       = $Object.FileName
                        SiteName       = $Object.SiteName
                        Hostname       = $Object.Hostname
                        HostIp         = $Object.HostIp
                        HttpMethod     = $Object.HttpMethod
                        Endpoint       = $Object.Endpoint
                        Query          = $Object.Query
                        LocalPort      = $Object.LocalPort
                        Username       = $Object.Username
                        ClientIp       = $Object.ClientIp
                        HttpVerion     = $Object.HttpVerion
                        Agent          = $Object.Agent
                        ClientCookie   = $Object.ClientCookie
                        URL            = $Object.URL
                        WebSite        = $Object.WebSite
                        HttpStatusCode = $Object.HttpStatusCode
                        Substatus      = $Object.Substatus
                        Win32Status    = $Object.Win32Status
                        SourceBytes    = $Object.SourceBytes
                        ClientBytes    = $Object.ClientBytes
                        ResponseTime   = $Object.ResponseTime
                        SourceIp       = $Object.SourceIp
                        Connection     = $Object.Connection
                        Warning        = $Object.Warning
                        HTTPConnection = $Object.HTTPConnection
                        Authorization  = $Object.Authorization
                    }
                    if (!($ShortMessage)) {
                        $ShortMessage = 'IIS'
                    }
                    if (!($FullMessage)) {
                        $FullMessage = $Object.EventDate + " IIS Logs Imported: $Today"
                    }
                    if (!($LogSource)) {
                        $LogSource = "$Hostname IIS Logs"
                    }
                    break;
                }
            }
            Send-PSGelfUDP -GelfServer $Server `
                -Port $Port `
                -ShortMessage "$ShortMessage" `
                -FullMessage "$FullMessage" `
                -DateTime "$Time" `
                -HostName "$Hostname" `
                -AdditionalField $LogData `
                -ErrorAction Ignore `
                -ErrorVariable Error
        }
    }
    end {
    }
}

function Update-EMTLGraylog {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0, Mandatory)]
        [string]$Path
    )
    begin {
        $CSV = Import-Csv -Path $Path
        $Today = Get-Date -Format MM/dd/yyyy
    }
    process {
        foreach ($Object in $CSV) {
            Send-PSGelfUDP -GelfServer '127.0.0.1' `
                -Port 12201 `
                -ShortMessage 'MessageTrackingLog' `
                -FullMessage "Exchange Message Tracking Logs Imported: $Today" `
                -DateTime $Object.Timestamp`
                -HostName '[MAILSERVERHOSTNAME]' `
                -AdditionalField @{
                EventId         = $Object.EventId
                Sender          = $Object.Sender
                ClientIp        = $Object.OriginalClientIp
                Connector       = $Object.ConnectorId
                Recipients      = $Object.Recipients
                RecipientStatus = $Object.RecipientStatus
            }
        }
    }
    end {
    }
}

Export-ModuleMember -Function Update-GrayLog,Update-EMTLGraylog
