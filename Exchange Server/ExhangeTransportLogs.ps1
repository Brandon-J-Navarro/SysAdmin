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
    Name: ExhangeTransportLogs.ps1
    Requires: 
    Major Release History:
                ?   - Initial Creation.
        07/25/2023  - Initial Release.
#>
Function init {
    $timestamp = Get-Date -Format 'yyyyMMddHHmmsss'
    $exch = Get-TransportService | Get-MessageTrackingLog -ResultSize unlimited | Select-Object eventid, sender, timestamp, OriginalClientIp, connectorid, @{Name = 'Recipients'; Expression = { $_.recipients } }, @{Name = 'RecipientStatus'; Expression = { $_.recipientstatus } }
    $exch | Export-Csv ('C:\Logs\Exchange\EXCH-mgs-tracking-{0}.csv' -f $timestamp) -NoTypeInformation
}
init
