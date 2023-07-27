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
	Name: AzureGovCloudShell.strings.psd1
	Requires: Administrator rights on the target server.
    Major Release History:
        02/27/2023 - Initial Release.

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
ConvertFrom-StringData @'
###PSLOC
res_welcome_message = \n         Welcome to the Azure Clould Shell!\n
res_full_list = Full list of cmdlets:
res_0003 = Get-Command
res_only_Azure_cmdlets = Only Azure cmdlets:
res_0005 = Get-AZCommand
res_cmdlets_specific_role = Cmdlets that match a specific string:
res_0007 = Get-Help *<string>*
res_general_help = Get general help:
res_0009 = Get-Help
res_help_for_cmdlet = Get help for a cmdlet:
res_0011 = Get-Help <cmdlet name> or <cmdlet name> -?
#res_updatable_help = 
# res_team_blog = 
# res_0015 = 
res_show_full_output = Show full output for a command:
res_0017 = <command> | Format-List\n
#res_0018 = 
res_0019 = Connecting to {0}.
res_0020 = Connected to {0} with account {1}.
res_0021 = Redirecting to Web Browser, Please Sign in.

###PSLOC
'@

# Welcome to the Azure Clould Shell!

# Full list of cmdlets: Get-Command
# Only Azure cmdlets: Get-AZCommand
# Cmdlets that match a specific string: Help *<string>*
# Get general help: Get-Help
# Get help for a cmdlet: Get-Help <cmdlet name> or <cmdlet name> -?
# Show full output for a command: <command> | Format-List

# Redirecting to Web Browser, Please Sign in.
# Connecting to AzureUSGovernment.
# Connected to AzureUSGovernment with account xxxxxxx@xxx.
