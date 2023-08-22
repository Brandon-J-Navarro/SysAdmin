<#
Released under MIT License

Copyright (c) 2023 Brandon J Navarro

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
    This script analyzes files in a directory, reads lines, and extracts strings enclosed in double and single quotes.

.DESCRIPTION
    This PowerShell script analyzes each file in a specified directory, reads its lines, and extracts all strings
    enclosed in both double and single quotes. It uses regular expressions to identify and extract the strings.
    
.PARAMETER directoryPath
    The path to the directory containing the files to be analyzed.

.PARAMETER exclude
    An array of file names or patterns to exclude from the analysis.

.NOTES
    File Name      : AnalyzeStrings.ps1
    Author         : Brandon J Navarro
    Prerequisite   : PowerShell 3.0 or later
    Copyright 2023 - Brandon J Navarro
    Released under MIT License

.EXAMPLE
    Example of how to use the script:
    .\AnalyzeStrings.ps1 -directoryPath "C:\path\to\your\directory" -exclude @("exclude_this.txt", "*.log")

#>

param (
    [string]$DirectoryPath,
    [string[]]$Exclude
)

function Extract-Strings {
    param (
        [string]$line
    )
    $doubleQuoted = [regex]::Matches($line, '"([^"]*)"') | ForEach-Object { $_.Groups[1].Value }
    $singleQuoted = [regex]::Matches($line, "'([^']*)'") | ForEach-Object { $_.Groups[1].Value }
    $doubleQuoted + $singleQuoted
}

function Analyze-Directory {
    param (
        [string]$Path,
        [string[]]$Exclude
    )
    begin{
        $objString = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    process{
        $files = Get-ChildItem -File $path | Where-Object { $exclude -notcontains $_.Name }
        foreach ($file in $files) {
            $lineNumber = 0
            Get-Content $file.FullName | ForEach-Object {
                $lineNumber++
                $strings = Extract-Strings $_
                if ($strings.Count -gt 0) {
                    $strings | ForEach-Object {
                        $objString.add([PSCustomObject]@{
                            "File" = $file.Name
                            "Line" = $lineNumber
                            "String" = $_
                        })
                    }
                }
            }
        }
    }
    end{
        return $objString
    }
}

Analyze-Directory -Path $DirectoryPath -Exclude $Exclude
