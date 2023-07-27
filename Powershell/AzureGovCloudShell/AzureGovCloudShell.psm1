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

# Version 202302

<#
.NOTES
	Name: AzureGovCloudShell.psm1
	Requires: Administrator rights on the target server.
    Major Release History:
        02/27/2023 - Initial Release.

.SYNOPSIS
	None

.DESCRIPTION
	None

.PARAMETER WebApplication
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None
#>
Import-LocalizedData -BindingVariable RemoteAzure_LocalizedStrings -FileName AzureGovCloudShell.strings.psd1

##Set Windows Terminal Profile or shortcut to
#C:\Program Files\PowerShell\7\pwsh.exe -NoProfile -NoExit -Command "Connect-AZGovCloud"

function Get-AZBanner
{
	write-host $RemoteAzure_LocalizedStrings.res_welcome_message

	write-host -no $RemoteAzure_LocalizedStrings.res_full_list
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0003

	write-host -no $RemoteAzure_LocalizedStrings.res_only_Azure_cmdlets
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0005

	write-host -no $RemoteAzure_LocalizedStrings.res_cmdlets_specific_role
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0007

	write-host -no $RemoteAzure_LocalizedStrings.res_general_help
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0009

	write-host -no $RemoteAzure_LocalizedStrings.res_help_for_cmdlet
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0011

	write-host -no $RemoteAzure_LocalizedStrings.res_show_full_output
	write-host -no " "
	write-host -fore Yellow $RemoteAzure_LocalizedStrings.res_0017

}

function prompt { 
	$cwd = (get-location).Path
	$host.UI.RawUI.WindowTitle = ($CommonConnectFunctions_LocalizedStrings.res_0004 -f $global:connectedFqdn)
	$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[AZ]")
	" $cwd>" 
}

function Get-AZCommand {
    Get-Command | Where-Object Source -Like "Az.*"
}

function Connect-AZGovCloud {
    [CmdletBinding()]
    param (
    )
    begin {
        Get-AZBanner
        Write-Host -fore Yellow $RemoteAzure_LocalizedStrings.res_0021
    }
    process {
        Connect-AzAccount -Environment AzureUSGovernment | Out-Null
        $AZAccount = Get-AzContext -Verbose
        Write-Host -fore Yellow ($RemoteAzure_LocalizedStrings.res_0019 -f $AZAccount.Environment)
        Start-Sleep 1s
    } 
    end {
        Write-Host -fore Yellow ($RemoteAzure_LocalizedStrings.res_0020 -f $AZAccount.Environment,$AZAccount.Account)
    }
}

Export-ModuleMember -Function Connect-AZGovCloud,Get-AZCommand,prompt
