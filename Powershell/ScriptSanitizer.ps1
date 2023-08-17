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

<#
.SYNOPSIS
    Sanitizes a PowerShell script by replacing specified words and phrases.

.DESCRIPTION
    This script reads a source PowerShell script line by line and searches for specified
    words or phrases. It then replaces them with other words or phrases, while ignoring case.

.PARAMETER SourceFilePath
    The path to the source PowerShell script to be sanitized.

.PARAMETER DestinationFilePath
    The path to save the sanitized version of the script.

.NOTES
    File Name      : ScriptSanitizer.ps1
    Author         : Brandon J. Navarro
    Prerequisite   : PowerShell 3.0 or later
    Copyright 2023 - Brandon J. Navarro
    Released under MIT License

.EXAMPLE
    Example of how to use the script:
    .\ScriptSanitizer.ps1 -SourceFilePath "C:\path\to\source\script.ps1" -DestinationFilePath "C:\path\to\destination\script_sanitized.ps1" -ReplacementMap $HashTable
#>

# Set strict mode for better coding practices
Set-StrictMode -Version Latest

#region: Set your environment
$HashTable = @{
    "word1" = "replacement1"
    "word2" = "replacement2"
    "phrase1" = "replacement3"
    "string" = [string]::Empty
    # Add more mappings as needed
}
$SourceFile = "C:\path\to\source\script.ps1"
$DestinationFile = $SourceFile.Replace(".ps1", "_Sanitized.ps1")
#endregion

#region: Functions

function Sanitize-Script {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceFilePath,

        [Parameter(Mandatory=$true)]
        [string]$DestinationFilePath,

        [Parameter(Mandatory=$true)]
        [hashtable]$ReplacementMap
    )

    # Initialize an empty list to store sanitized lines
    $sanitizedLines = @()

    Get-Content -Path $SourceFilePath | ForEach-Object {
        $line = $_

        # Loop through each mapping and perform case-insensitive replacement
        foreach ($key in $ReplacementMap.Keys) {
            $replacement = $ReplacementMap[$key]
            $line = $line -ireplace [regex]::Escape($key), $replacement
        }

        # Add the sanitized line to the list
        $sanitizedLines += $line
    }

    # Write the sanitized lines to the destination file
    $sanitizedLines | Out-File -FilePath $DestinationFilePath -Encoding UTF8

    Write-Host "Script sanitized and saved to $DestinationFilePath."
}

#endregion

#region: Main Script

# Call the function to sanitize the script
Sanitize-Script -SourceFilePath $SourceFile -DestinationFilePath $DestinationFile -ReplacementMap $HashTable

#endregion
