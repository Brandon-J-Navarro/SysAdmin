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
    Connects to an Exchange Server using various connection options.

.DESCRIPTION
    This script function, Connect-ExchangeServer, allows you to establish a connection to an Exchange Server using different connection methods. You can connect using a specified server's fully qualified domain name (FQDN), auto-discovery with user credentials, or by manually inputting the FQDN. The script provides options for handling cached sessions and clobbering.

.PARAMETER ServerFqdn
    Specifies the fully qualified domain name (FQDN) of the Exchange Server to connect to.

.PARAMETER Auto
    Switch parameter. If present, the script will attempt to automatically discover and connect to the appropriate Exchange Server based on the user's credentials and forest information.

.PARAMETER Prompt
    Switch parameter. When no server FQDN is provided and this switch is present, the script will prompt the user for input.

.PARAMETER UserName
    Specifies the username for connecting to the Exchange Server. If provided, a PSCredential object will be created using the Get-Credential cmdlet.

.PARAMETER UserCredential
    Provides a PSCredential object for authentication instead of using the UserName parameter. Overrides the use of Windows Integrated Authentication (WIA).

.PARAMETER Forest
    Specifies the forest information when using the Auto switch for auto-discovery. If this parameter is provided, it will be used alongside user credentials to discover and connect to the appropriate Exchange Server.

.PARAMETER ClearCache
    Switch parameter. If present, the cached session will be cleared before importing a new session.

.PARAMETER ClientApplication
    Specifies the client application information for the connection.

.PARAMETER AllowClobber
    Switch parameter. If present, allows the ImportPSSession cmdlet to overwrite conflicting cmdlet and function names in the current session.

.NOTES
    File Name      : ConnectFunctions.ps1
    Author         : Brandon J. Navarro
    Prerequisite   : PowerShell 3.0 or later
    Copyright 2023 - Brandon J. Navarro
    Released under MIT License
    Additional Info: This is a modified version of the Connect-ExchangeServer function that is avaliable on Exchange Server allowing to pass in a PSCredential and not have to be prompted for credentials.

.EXAMPLE
    Connect-ExchangeServer -ServerFqdn "exchangeserver01.contoso.com" -UserName "user1" -ClearCache

.EXAMPLE
    Connect-ExchangeServer -Auto -UserCredential $cred -Forest "contoso.com" -AllowClobber
#>

function Connect-ExchangeServer ($ServerFqdn, [switch]$Auto, [switch]$Prompt, $UserName, [PSCredential]$UserCredential, $Forest,[switch]$ClearCache, $ClientApplication=$null, [switch]$AllowClobber)
{
#.EXTERNALHELP Connect-ExchangeServer-help.xml
    set-variable VerbosePreference -value Continue
    :connectScope do
    {
        if (!$Auto -and ($ServerFqdn -eq $null) -and !$Prompt)
        {
            _PrintUsageAndQuit
        }

        $useWIA = $true
        if (!($UserCredential -eq $null))
        {
            $credential = $UserCredential
            $useWIA = $false
        }elseif(!($username -eq $null)){
            $credential = get-credential $username
            $useWIA = $false
        }


        if (!($ServerFqdn -eq $null))
        {
            if ($Auto -or !($Forest -eq $null)) { _PrintUsageAndQuit }

            _OpenExchangeRunspace $ServerFqdn $credential $useWIA -ClientApplication:$ClientApplication
        }

        if ($Auto)
        {
            # We should provide the $credential before $Forest, and we cannot assume useWIA $true here. It should be read from $useWIA
            _AutoDiscoverAndConnect $credential $Forest -useWIA:$useWIA -ClientApplication:$ClientApplication
        }
        else
        {
            if (!($Forest -eq $null)) { _PrintUsageAndQuit }
        }

        Write-Host $ConnectFunctions_LocalizedStrings.res_0000
        $fqdn=read-host -prompt $ConnectFunctions_LocalizedStrings.res_0001
        _OpenExchangeRunspace $fqdn $credential $useWIA -ClientApplication:$ClientApplication
    }
    while ($false) #connectScope
        
    if ($ClearCache)
    {
        if ($AllowClobber)
        {
            ImportPSSession -ClearCache:$true -AllowClobber
        }
        else
        {
            ImportPSSession -ClearCache:$true
        }
    }
    else
    {
        if ($AllowClobber)
        {
            ImportPSSession -ClearCache:$false -AllowClobber
        }
        else
        {
            ImportPSSession -ClearCache:$false
        }
    }
}
