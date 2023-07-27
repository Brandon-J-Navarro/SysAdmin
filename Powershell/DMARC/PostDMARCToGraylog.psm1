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
    Name: PostDMARCToGraylog.ps1
    Requires: 
    Major Release History:
        07/11/2023  - Initial Creation.
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
    $Path = Get-ChildItem -LiteralPath "C:\DMARC\Reports\" -Recurse -File
    $Path | ForEach-Object {
        Update-DMARCGraylog -Path $_.FullName
        Move-Item -LiteralPath $_.FullName -Destination "C:\DMARC\Reports\Ingested"
    }

#>
function Update-DMARCGraylog {
    [CmdletBinding()]
    param (
        [Parameter (Position = 0, Mandatory)]
        [string]$Path
    )
    begin {
        $CSV = Import-Csv -LiteralPath $Path
        $Today = Get-Date -Format MM/dd/yyyy
    }
    process {
        foreach ($Object in $CSV) {
            $org = $Object.ReportingOrg
            Send-PSGelfUDP -GelfServer '127.0.0.1' `
                -Port 12201 `
                -ShortMessage 'DMARC' `
                -FullMessage "$org DMARC Logs Imported: $Today" `
                -DateTime $Object.ReportDate`
                -HostName $Object.ReportingOrg `
                -AdditionalField @{StartTime = $Object.StartTime
                EndTime                      = $Object.EndTime
                HostIp                       = $Object.HostIp
                ReportID                     = $Object.ReportID
                ReportingOrg                 = $Object.ReportingOrg
                ReportingEmail               = $Object.ReportingEmail
                FileName                     = $Object.FileName
                DKIMResults                  = $Object.DKIMResults
                SPFResults                   = $Object.SPFResults
                EvaluatedDomain              = $Object.Domain
                EmailFromDomain              = $Object.FromDomain
                EmailToDomain                = $Object.ToDomain
            }
        }
    }
    end {
    }
}

Export-ModuleMember Update-DMARCGraylog
