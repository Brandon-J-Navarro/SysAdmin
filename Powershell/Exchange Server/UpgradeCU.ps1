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

# EXCHANGE CU UPGRADE

# Enter Maintenace Mode (Exchange)
    Set-ServerComponentState -Identity "[HOSTNAME]" -Component HubTransport -State Draining -Requester Maintenance
    Set-MailboxServer "[HOSTNAME]" -DatabaseCopyActivationDisabledAndMoveNow $true
    Set-MailboxServer "[HOSTNAME]" -DatabaseCopyAutoActivationPolicy Blocked
    Set-ServerComponentState "[HOSTNAME]" -Component ServerWideOffline -State Inactive -Requester Maintenance
    Get-ServerComponentState "[HOSTNAME]” | Select-Object Component, State

# Run From Command Prompt (CMD)
E:\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms_DiagnosticDataOff
E:\Setup.exe /PrepareAD /IAcceptExchangeServerLicenseTerms_DiagnosticDataOff
E:\Setup.exe /PrepareDomain /IAcceptExchangeServerLicenseTerms_DiagnosticDataOff
E:\Setup.exe /Mode:Upgrade /IAcceptExchangeServerLicenseTerms_DiagnosticDataOff

# Exit Maintenace Mode (Exchange)
    Set-ServerComponentState “[HOSTNAME]” -Component ServerWideOffline -State Active -Requester Maintenanc
    Set-ServerComponentState "[HOSTNAME]" -Component HubTransport -State Active -Requester Maintenance
    Set-MailboxServer "[HOSTNAME]" -DatabaseCopyAutoActivationPolicy Unrestricted
    Set-MailboxServer "[HOSTNAME]" -DatabaseCopyActivationDisabledAndMoveNow $false
    Set-ServerComponentState “[HOSTNAME]” -Component ServerWideOffline -State Active -Requester Maintenance
    Set-ServerComponentState "[HOSTNAME]" -Component HubTransport -State Active -Requester Maintenance

    Configuring Microsoft Exchange Server

# Preparing Setup                                       COMPLETED
# Stopping Services                                     COMPLETED
# Language Files                                        COMPLETED
# Removing Exchange Files                               COMPLETED
# Preparing Files                                       COMPLETED
# Copying Exchange Files                                COMPLETED
# Language Files                                        COMPLETED
# Restoring Services                                    COMPLETED
# Language Configuration                                COMPLETED
# Exchange Management Tools                             COMPLETED
# Mailbox role: Transport service                       COMPLETED
# Mailbox role: Client Access service                   COMPLETED
# Mailbox role: Unified Messaging service               COMPLETED
# Mailbox role: Mailbox service                         COMPLETED
# Mailbox role: Front End Transport service             COMPLETED
# Mailbox role: Client Access Front End service         COMPLETED
# Finalizing Setup                                      COMPLETED
