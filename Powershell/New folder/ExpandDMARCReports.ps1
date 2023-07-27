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
    Name: ExpandDMARCReport.ps1
    Requires: 
    Major Release History:
        04/21/2023  - Initial Creation.
        04/26/2023  - Initial Release.
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
$DMARCSource = "C:\DMARC\Source"
$Temp = "C:\DMARC\Temp"
$Outlook = 'C:\DMARC\Outlook'
$Google = 'C:\DMARC\Google'
$Yahoo = 'C:\DMARC\Yahoo'


Set-Location $DMARCSource

$DMARC = Get-ChildItem -Path $DMARCSource
$DMARC | ForEach-Object {
    if($_.Extension -Like ".zip"){
        ForEach-Object { 
            $Name = $_.Name.Replace('.zip','')
            Expand-Archive -Path $_.FullName -DestinationPath ("$Temp\{0}" -f $Name)
            Remove-Item -Path $_.FullName
        }
    }elseif ($_.Extension -Like ".gz") {
        wsl.exe gzip -d *.gz
        Get-ChildItem -Path $DMARCSource  | Where-Object Extension -Like .xml | 
        Move-Item -Destination $Temp
    }
}

$DMARCDestination = Get-ChildItem -Path $Temp -Recurse
$DMARCDestination | ForEach-Object {
    if($_.name -like "*outlook*") {
        $_ | Move-Item -Destination $Outlook
    }elseif ($_.name -like "*google*") {
        $_ | Move-Item -Destination $Google
    }elseif($_.name -like "*yahoo*") {
        $_ | Move-Item -Destination $Yahoo
    }else {
        Write-Host ( 'No Predifined Location to move "{0}" to.' -f $_.name)
    }
}

Set-Location "C:\"
