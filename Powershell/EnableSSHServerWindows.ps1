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

Add-WindowsCapability -Online -Name OpenSSH.Server*
#Path          :
#Online        : True
#RestartNeeded : False

ssh-keygen -b 4096 -t rsa
#Generating public/private rsa key pair.
#Enter file in which to save the key (C:\Users\<#USERNAME#>/.ssh/id_rsa):
#Created directory 'C:\Users\<#USERNAME#>/.ssh'.
#Enter passphrase (empty for no passphrase):
#Enter same passphrase again:
#Your identification has been saved in C:\Users\<#USERNAME#>/.ssh/id_rsa.
#Your public key has been saved in C:\Users\<#USERNAME#>/.ssh/id_rsa.pub.
#The key fingerprint is:

set-service ssh-agent -StartupType ‘Automatic’
Start-Service ssh-agent
set-service sshd -StartupType ‘Automatic’
Start-Service sshd

#Copy Contents of C:\Users\<#USERNAME#>/.ssh/id_rsa.pub and create C:\Users\<#USERNAME#>/.ssh/authorized_keys

#Make changes to ssh config file C:\ProgramData\ssh\sshd_config
<#
StrictModes no
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication no
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo -NoProfile
#Match Group administrators
#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
#>

Restart-Service sshd

Get-WindowsCapability -online -Name openssh.server*

#Name         : OpenSSH.Server~~~~0.0.1.0
#State        : Installed
#DisplayName  : OpenSSH Server
#Description  : OpenSSH-based secure shell (SSH) server, for secure key management and access from
#               remote machines.
#DownloadSize : 1405120
#InstallSize  : 5439396

#Copy the generated id_rsa file to the computer you want to ssh from 
ssh <#UserName@HostName-OR-IPAddress#> -i C:\FILE\PATH\id_rsa

<#$VariableName#> = New-PSSession -HostName <#HostName-OR-IPAddress#> -UserName <#UserName#> -KeyFilePath 'C:\File\Path\id_rsa'

Invoke-Command -Session <#$VariableName#> -ScriptBlock {
}
