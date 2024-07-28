# Open Powershell As Administrator

winrm quickconfig

Get-Item wsman:\localhost\client\TrustedHosts

Set-Item wsman:\localhost\client\TrustedHosts -Value #Ip address or hostname
