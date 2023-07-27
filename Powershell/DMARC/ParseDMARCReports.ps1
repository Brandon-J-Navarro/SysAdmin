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
	Name: ParseDMARCReports.ps1
	Requires: 
    Major Release History:
        06/05/2023  - Initial Creation.
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

$paths = @(
    'C:\DMARC\Google\',
    'C:\DMARC\Outlook\',
    'C:\DMARC\Yahoo\'
)

$objDMARCContent = [System.Collections.Generic.List[PSCustomObject]]::new()

$paths | ForEach-Object {
    $report = Get-ChildItem -Path $_ -Recurse | Where-Object { $_.Name -like '*.xml' }
    $report | ForEach-Object {
        $filename = $_.name
        $reportdate = $_.LastWriteTime
        [xml]$contents = Get-Content -Path $_.FullName
        $ReportOrg = $contents.feedback.report_metadata.org_name
        $ReportEmail = $contents.feedback.report_metadata.email
        $reportID = $contents.feedback.report_metadata.report_id
        $starttime = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($contents.feedback.report_metadata.date_range.begin))  
        $endtime = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($contents.feedback.report_metadata.date_range.end))
        $domain = $contents.feedback.policy_published.domain
        $contents.feedback.record | ForEach-Object {
            $ip = $_.row.source_ip
            $dkimresults = $_.row.policy_evaluated.dkim
            $spfresults = $_.row.policy_evaluated.spf
            $fromdomain = $_.identifiers.header_from
            $todomain = $_.identifiers.envelope_to
            $objDMARCContent.add([PSCustomObject]@{
                'ReportDate'   = $reportdate
                'HostIp'       = $ip
                'DKIMResults'  = $dkimresults
                'SPFResults'   = $spfresults
                'FileName'     = $filename
                'ReportID'     = $ReportID
                'StartTime'    = $starttime
                'EndTime'      = $endtime
                'Domain'       = $domain
                'ReportingOrg' = $ReportOrg
                'ReportingEmail' = $ReportEmail
                'FromDomain' = $fromdomain
                'ToDomain' = $todomain
            })
        }
    }
}

$Now = Get-CustomLogTimestamp

$objDMARCContent | Export-Csv -Path ("C:\DMARC\Reports\{0}DMARCReports.csv" -f $now)
